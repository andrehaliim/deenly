package com.andrehaliim.deenly

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class DeenlyWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.deenly_widget)

            val prefs = HomeWidgetPlugin.getData(context)
            // Prayer times
            views.setTextViewText(R.id.fajr_time, prefs.getString("fajr_time", "--:--"))
            views.setTextViewText(R.id.dhuhr_time, prefs.getString("dhuhr_time", "--:--"))
            views.setTextViewText(R.id.asr_time, prefs.getString("asr_time", "--:--"))
            views.setTextViewText(R.id.maghrib_time, prefs.getString("maghrib_time", "--:--"))
            views.setTextViewText(R.id.isha_time, prefs.getString("isha_time", "--:--"))
            views.setTextViewText(R.id.gregorian_date, prefs.getString("gregorian_date", "Error gregorian"))
            views.setTextViewText(R.id.hijri_date, prefs.getString("hijri_date", "Error Hijri"))

            views.setTextViewText(R.id.location, prefs.getString("location", "Error location"))

            // 🔔 Notification icons
            val fajrNotif = prefs.getBoolean("fajr_notification", false)
            views.setImageViewResource(
                R.id.fajr_notification,
                if (fajrNotif) R.drawable.ic_notification_on else R.drawable.ic_notification_off
            )

            val dhuhrNotif = prefs.getBoolean("dhuhr_notification", false)
            views.setImageViewResource(
                R.id.dhuhr_notification,
                if (dhuhrNotif) R.drawable.ic_notification_on else R.drawable.ic_notification_off
            )

            val asrNotif = prefs.getBoolean("asr_notification", false)
            views.setImageViewResource(
                R.id.asr_notification,
                if (asrNotif) R.drawable.ic_notification_on else R.drawable.ic_notification_off
            )

            val maghribNotif = prefs.getBoolean("maghrib_notification", false)
            views.setImageViewResource(
                R.id.maghrib_notification,
                if (maghribNotif) R.drawable.ic_notification_on else R.drawable.ic_notification_off
            )

            val ishaNotif = prefs.getBoolean("isha_notification", false)
            views.setImageViewResource(
                R.id.isha_notification,
                if (ishaNotif) R.drawable.ic_notification_on else R.drawable.ic_notification_off
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}