package com.andrehaliim.deenly

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar

class DeenlyWidget : AppWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_REFRESH_NEXT_PRAYER,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_DATE_CHANGED -> refreshAll(context)
        }
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
        val prefs = HomeWidgetPlugin.getData(context)
        val nextPrayer = findNextPrayer(prefs, Calendar.getInstance())

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.deenly_widget)

            // Prayer times
            views.setTextViewText(R.id.fajr_time, prefs.getString("fajr_time", "--:--"))
            views.setTextViewText(R.id.dhuhr_time, prefs.getString("dhuhr_time", "--:--"))
            views.setTextViewText(R.id.asr_time, prefs.getString("asr_time", "--:--"))
            views.setTextViewText(R.id.maghrib_time, prefs.getString("maghrib_time", "--:--"))
            views.setTextViewText(R.id.isha_time, prefs.getString("isha_time", "--:--"))
            views.setTextViewText(
                    R.id.gregorian_date,
                    prefs.getString("gregorian_date", "Error gregorian")
            )
            views.setTextViewText(R.id.hijri_date, prefs.getString("hijri_date", "Error Hijri"))
            views.setTextViewText(R.id.location, prefs.getString("location", "Error location"))

            // 🔔 Notification icons
            val notificationMap =
                    mapOf(
                            "fajr_notification" to R.id.fajr_notification,
                            "dhuhr_notification" to R.id.dhuhr_notification,
                            "asr_notification" to R.id.asr_notification,
                            "maghrib_notification" to R.id.maghrib_notification,
                            "isha_notification" to R.id.isha_notification
                    )

            notificationMap.forEach { (prefKey, viewId) ->
                val enabled = prefs.getBoolean(prefKey, false)

                views.setImageViewResource(
                        viewId,
                        if (enabled) {
                            R.drawable.ic_notification_on
                        } else {
                            R.drawable.ic_notification_off
                        }
                )
            }

            val nextPrayerName = nextPrayer?.name ?: "Prayer"
            views.setTextViewText(
                    R.id.next_prayer_name,
                    nextPrayerName.replaceFirstChar { it.uppercase() }
            )

            data class PrayerViewIds(
                    val row: Int,
                    val name: Int,
                    val time: Int,
                    val notification: Int
            )

            val prayerViewMap =
                    mapOf(
                            "fajr" to
                                    PrayerViewIds(
                                            R.id.fajr_row,
                                            R.id.fajr_name,
                                            R.id.fajr_time,
                                            R.id.fajr_notification
                                    ),
                            "dhuhr" to
                                    PrayerViewIds(
                                            R.id.dhuhr_row,
                                            R.id.dhuhr_name,
                                            R.id.dhuhr_time,
                                            R.id.dhuhr_notification
                                    ),
                            "asr" to
                                    PrayerViewIds(
                                            R.id.asr_row,
                                            R.id.asr_name,
                                            R.id.asr_time,
                                            R.id.asr_notification
                                    ),
                            "maghrib" to
                                    PrayerViewIds(
                                            R.id.maghrib_row,
                                            R.id.maghrib_name,
                                            R.id.maghrib_time,
                                            R.id.maghrib_notification
                                    ),
                            "isha" to
                                    PrayerViewIds(
                                            R.id.isha_row,
                                            R.id.isha_name,
                                            R.id.isha_time,
                                            R.id.isha_notification
                                    ),
                    )

            prayerViewMap.values.forEach { ids ->
                val defaultColor = ContextCompat.getColor(context, R.color.lightNeutral)
                views.setInt(ids.row, "setBackgroundResource", R.drawable.rounded_grey_background)
                views.setTextColor(ids.name, defaultColor)
                views.setTextColor(ids.time, defaultColor)
                views.setInt(ids.notification, "setColorFilter", defaultColor)
            }

            prayerViewMap[nextPrayerName]?.let { ids ->
                val primaryColor = ContextCompat.getColor(context, R.color.lightPrimary)
                views.setInt(ids.row, "setBackgroundResource", R.drawable.rounded_white_background)
                views.setTextColor(ids.name, primaryColor)
                views.setTextColor(ids.time, primaryColor)
                views.setInt(ids.notification, "setColorFilter", primaryColor)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        scheduleNextRefresh(context, nextPrayer)
    }

    private data class NextPrayer(val name: String, val triggerAtMillis: Long)

    companion object {
        private const val ACTION_REFRESH_NEXT_PRAYER =
                "com.andrehaliim.deenly.action.REFRESH_NEXT_PRAYER"
        private const val REFRESH_REQUEST_CODE = 1001

        private val PRAYER_NAMES = listOf("fajr", "dhuhr", "asr", "maghrib", "isha")

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

        /**
         * Returns the first prayer whose time is still ahead of [now], or
         * tomorrow's Fajr once Isha has passed. Mirrors
         * PrayerProxy.getNextPrayer on the Flutter side.
         */
        private fun findNextPrayer(prefs: SharedPreferences, now: Calendar): NextPrayer? {
            for (name in PRAYER_NAMES) {
                val time = prayerTimeToday(prefs, name, now) ?: continue
                if (time.after(now)) return NextPrayer(name, time.timeInMillis)
            }
            val fajr = prayerTimeToday(prefs, "fajr", now) ?: return null
            fajr.add(Calendar.DAY_OF_MONTH, 1)
            return NextPrayer("fajr", fajr.timeInMillis)
        }

        private fun prayerTimeToday(
                prefs: SharedPreferences,
                name: String,
                now: Calendar
        ): Calendar? {
            val parts = prefs.getString("${name}_time", null)?.split(":") ?: return null
            if (parts.size != 2) return null
            val hour = parts[0].trim().toIntOrNull() ?: return null
            val minute = parts[1].trim().toIntOrNull() ?: return null

            return (now.clone() as Calendar).apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
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

        /** Wakes the widget up right when the next prayer time arrives. */
        private fun scheduleNextRefresh(context: Context, nextPrayer: NextPrayer?) {
            val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return
            val pendingIntent = refreshPendingIntent(context)

            if (nextPrayer == null) {
                alarmManager.cancel(pendingIntent)
                return
            }

            val canExact =
                    Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                            alarmManager.canScheduleExactAlarms()

            if (canExact) {
                alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        nextPrayer.triggerAtMillis,
                        pendingIntent
                )
            } else {
                alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        nextPrayer.triggerAtMillis,
                        pendingIntent
                )
            }
        }
    }
}
