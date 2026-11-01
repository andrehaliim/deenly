package com.andrehaliim.deenly

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Build
import android.text.format.DateFormat
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar
import java.util.Locale
import kotlin.math.ceil

class DeenlyWidget : AppWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_REFRESH_NEXT_PRAYER,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> refreshAll(context)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        WidgetTheme.delete(context, appWidgetIds)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        val alarmManager = context.getSystemService(AlarmManager::class.java)
        alarmManager?.cancel(refreshPendingIntent(context))
    }

    override fun onUpdate(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
    ) {
        val now = Calendar.getInstance()

        for (widgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(
                    widgetId,
                    buildViews(context, WidgetTheme.of(context, widgetId))
            )
        }

        // Prayer times and midnight fall on minute boundaries, so the
        // per-minute countdown refresh also covers them.
        val nextMinute =
                (now.clone() as Calendar).apply {
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                    add(Calendar.MINUTE, 1)
                }
        scheduleNextRefresh(context, nextMinute.timeInMillis)
    }

    private data class NextPrayer(val name: String, val triggerAtMillis: Long)

    private data class PrayerViewIds(
            val row: Int,
            val icon: Int,
            val name: Int,
            val time: Int,
            val period: Int,
            val label: Int
    )

    companion object {
        private const val ACTION_REFRESH_NEXT_PRAYER =
                "com.andrehaliim.deenly.action.REFRESH_NEXT_PRAYER"
        private const val REFRESH_REQUEST_CODE = 1001
        private const val TITLE_TEXT_SIZE_SP = 24f

        private val PRAYER_NAMES = listOf("fajr", "dhuhr", "asr", "maghrib", "isha")

        private val PRAYER_VIEWS =
                mapOf(
                        "fajr" to
                                PrayerViewIds(
                                        R.id.fajr_row,
                                        R.id.fajr_icon,
                                        R.id.fajr_name,
                                        R.id.fajr_time,
                                        R.id.fajr_period,
                                        R.string.fajr_name
                                ),
                        "dhuhr" to
                                PrayerViewIds(
                                        R.id.dhuhr_row,
                                        R.id.dhuhr_icon,
                                        R.id.dhuhr_name,
                                        R.id.dhuhr_time,
                                        R.id.dhuhr_period,
                                        R.string.dhuhr_name
                                ),
                        "asr" to
                                PrayerViewIds(
                                        R.id.asr_row,
                                        R.id.asr_icon,
                                        R.id.asr_name,
                                        R.id.asr_time,
                                        R.id.asr_period,
                                        R.string.asr_name
                                ),
                        "maghrib" to
                                PrayerViewIds(
                                        R.id.maghrib_row,
                                        R.id.maghrib_icon,
                                        R.id.maghrib_name,
                                        R.id.maghrib_time,
                                        R.id.maghrib_period,
                                        R.string.maghrib_name
                                ),
                        "isha" to
                                PrayerViewIds(
                                        R.id.isha_row,
                                        R.id.isha_icon,
                                        R.id.isha_name,
                                        R.id.isha_time,
                                        R.id.isha_period,
                                        R.string.isha_name
                                ),
                )

        /** Key prefixes written by WidgetHelper.updateWidgetPrayer. */
        private const val TODAY = ""
        private const val TOMORROW = "tomorrow_"

        /** The widget drawn with [theme]; also the live preview in [WidgetThemeActivity]. */
        fun buildViews(context: Context, theme: WidgetTheme): RemoteViews {
            val prefs = HomeWidgetPlugin.getData(context)
            val now = Calendar.getInstance()
            val day = currentDayPrefix(prefs, now)
            val nextPrayer = findNextPrayer(prefs, day, now)
            val is24Hour = DateFormat.is24HourFormat(context)
            fun color(res: Int) = ContextCompat.getColor(context, res)

            val views = RemoteViews(context.packageName, R.layout.deenly_widget)

            views.setInt(android.R.id.background, "setBackgroundResource", theme.card)
            views.setInt(R.id.location_chip, "setBackgroundResource", theme.chip)
            views.setInt(R.id.next_prayer_box, "setBackgroundResource", theme.nextBox)

            // A transparent filter leaves the launcher artwork's own colors.
            views.setInt(
                    R.id.widget_logo,
                    "setColorFilter",
                    if (theme.logoKeepsColors) Color.TRANSPARENT else color(theme.brand)
            )
            views.setImageViewBitmap(R.id.widget_title, renderTitle(context, color(theme.brand)))
            views.setViewVisibility(R.id.widget_title_fallback, View.GONE)
            views.setInt(R.id.location_icon, "setColorFilter", color(theme.accent))
            views.setInt(R.id.next_prayer_icon, "setColorFilter", color(theme.accent))
            views.setTextColor(R.id.location, color(theme.brand))
            views.setTextColor(R.id.next_prayer_label, color(theme.secondaryText))
            views.setTextColor(R.id.remaining_label, color(theme.secondaryText))
            views.setTextColor(R.id.next_prayer_name, color(theme.nextName))
            views.setTextColor(R.id.next_prayer_countdown, color(theme.countdown))

            views.setTextViewText(R.id.location, prefs.getString("location", "Error location"))

            PRAYER_VIEWS.forEach { (name, ids) ->
                val active = name == nextPrayer?.name
                val (time, period) =
                        formatTime(prefs.getString("$day${name}_time", null), is24Hour)

                views.setTextViewText(ids.time, time)
                views.setTextViewText(ids.period, period)
                views.setViewVisibility(ids.period, if (period.isEmpty()) View.GONE else View.VISIBLE)

                views.setInt(
                        ids.row,
                        "setBackgroundResource",
                        if (active) theme.tileActive else theme.tile
                )
                views.setInt(
                        ids.icon,
                        "setColorFilter",
                        color(if (active) theme.activeAccent else theme.tileIcon)
                )
                views.setTextColor(
                        ids.name,
                        color(if (active) theme.activeText else theme.tileIcon)
                )
                views.setTextColor(
                        ids.time,
                        color(if (active) theme.activeAccent else theme.tileTime)
                )
                views.setTextColor(
                        ids.period,
                        color(if (active) theme.activeText else theme.tilePeriod)
                )
            }

            views.setTextViewText(
                    R.id.next_prayer_name,
                    PRAYER_VIEWS[nextPrayer?.name]?.let { context.getString(it.label) }
                            ?: context.getString(R.string.prayer_default)
            )

            views.setTextViewText(
                    R.id.next_prayer_countdown,
                    nextPrayer?.let { formatRemaining(it.triggerAtMillis - now.timeInMillis) }
                            ?: context.getString(R.string.no_time)
            )

            return views
        }

        /** Redraws [widgetIds], e.g. after [WidgetThemeActivity] changed a theme. */
        fun update(context: Context, widgetIds: IntArray) {
            DeenlyWidget().onUpdate(context, AppWidgetManager.getInstance(context), widgetIds)
        }

        private fun refreshAll(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val ids =
                    appWidgetManager.getAppWidgetIds(
                            ComponentName(context, DeenlyWidget::class.java)
                    )
            if (ids.isNotEmpty()) {
                DeenlyWidget().onUpdate(context, appWidgetManager, ids)
            }
        }

        private fun startOfDay(now: Calendar, daysFromNow: Int): Calendar =
                (now.clone() as Calendar).apply {
                    add(Calendar.DAY_OF_MONTH, daysFromNow)
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }

        /** Same 'dd-MM-yyyy' format as PrayerModel.date. */
        private fun dateKey(day: Calendar): String =
                String.format(
                        Locale.US,
                        "%02d-%02d-%04d",
                        day.get(Calendar.DAY_OF_MONTH),
                        day.get(Calendar.MONTH) + 1,
                        day.get(Calendar.YEAR)
                )

        /** Tomorrow's copy once the date rolled over before the app refreshed. */
        private fun currentDayPrefix(prefs: SharedPreferences, now: Calendar): String =
                if (prefs.getString("${TOMORROW}date", null) == dateKey(now)) TOMORROW else TODAY

        /** Mirrors PrayerProxy.getNextPrayer on the Flutter side. */
        private fun findNextPrayer(
                prefs: SharedPreferences,
                day: String,
                now: Calendar
        ): NextPrayer? {
            val today = startOfDay(now, 0)
            for (name in PRAYER_NAMES) {
                val time = prayerTimeOn(prefs, "$day${name}_time", today) ?: continue
                if (time.after(now)) return NextPrayer(name, time.timeInMillis)
            }

            val tomorrow = startOfDay(now, 1)
            val hasTomorrow =
                    day == TODAY && prefs.getString("${TOMORROW}date", null) == dateKey(tomorrow)
            val fajrKey = if (hasTomorrow) "${TOMORROW}fajr_time" else "${day}fajr_time"
            val fajr = prayerTimeOn(prefs, fajrKey, tomorrow) ?: return null
            return NextPrayer("fajr", fajr.timeInMillis)
        }

        /** 'HH:mm' as-is in 24-hour mode, otherwise 'h:mm' plus 'AM'/'PM'. */
        private fun formatTime(value: String?, is24Hour: Boolean): Pair<String, String> {
            val parts = value?.split(":")
            val hour = parts?.getOrNull(0)?.trim()?.toIntOrNull()
            val minute = parts?.getOrNull(1)?.trim()?.toIntOrNull()
            if (hour == null || minute == null) return (value ?: "--:--") to ""
            if (is24Hour) return value.trim() to ""

            val hour12 = if (hour % 12 == 0) 12 else hour % 12
            return String.format(Locale.US, "%d:%02d", hour12, minute) to
                    if (hour < 12) "AM" else "PM"
        }

        /** App title in the home screen's brand font (Noto Serif SemiBold Italic). */
        private fun renderTitle(context: Context, color: Int): Bitmap {
            val text = context.getString(R.string.widget_title)
            val paint =
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        typeface = ResourcesCompat.getFont(context, R.font.noto_serif_semibold_italic)
                        textSize =
                                TypedValue.applyDimension(
                                        TypedValue.COMPLEX_UNIT_SP,
                                        TITLE_TEXT_SIZE_SP,
                                        context.resources.displayMetrics
                                )
                        this.color = color
                    }
            val metrics = paint.fontMetrics
            // Extra width so the italic overhang isn't clipped.
            val width = ceil(paint.measureText(text) + paint.textSize * 0.15f).toInt()
            val height = ceil(metrics.descent - metrics.ascent).toInt()

            return Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).apply {
                Canvas(this).drawText(text, 0f, -metrics.ascent, paint)
            }
        }

        /** 'hh:mm' left, rounded up so it never shows 00:00 before the prayer. */
        private fun formatRemaining(millis: Long): String {
            val minutes = (millis.coerceAtLeast(0) + 59_999) / 60_000
            return String.format(Locale.US, "%02d:%02d", minutes / 60, minutes % 60)
        }

        private fun prayerTimeOn(prefs: SharedPreferences, key: String, day: Calendar): Calendar? {
            val parts = prefs.getString(key, null)?.split(":") ?: return null
            if (parts.size != 2) return null
            val hour = parts[0].trim().toIntOrNull() ?: return null
            val minute = parts[1].trim().toIntOrNull() ?: return null

            return (day.clone() as Calendar).apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
            }
        }

        private fun refreshPendingIntent(context: Context): PendingIntent {
            val intent =
                    Intent(context, DeenlyWidget::class.java).apply {
                        action = ACTION_REFRESH_NEXT_PRAYER
                    }
            return PendingIntent.getBroadcast(
                    context,
                    REFRESH_REQUEST_CODE,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        /**
         * Called with the next minute. RTC (not RTC_WAKEUP) so a sleeping
         * phone isn't woken every minute; a missed refresh runs on wake.
         */
        private fun scheduleNextRefresh(context: Context, triggerAtMillis: Long) {
            val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return
            val pendingIntent = refreshPendingIntent(context)

            val canExact =
                    Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                            alarmManager.canScheduleExactAlarms()

            if (canExact) {
                alarmManager.setExact(AlarmManager.RTC, triggerAtMillis, pendingIntent)
            } else {
                alarmManager.set(AlarmManager.RTC, triggerAtMillis, pendingIntent)
            }
        }
    }
}
