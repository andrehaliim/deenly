import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

const String dailyTaskName = "daily_refresh_prayer";

class WorkmanagerHelper {
  static Future<void> scheduleDailyNotification() async {
    final now = DateTime.now();

    var scheduledTime = DateTime(now.year, now.month, now.day, 00, 05);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final initialDelays = scheduledTime.difference(now);

    await Workmanager().registerOneOffTask(
      "dailyNotificationTask",
      dailyTaskName,
      initialDelay: initialDelays,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> scheduleNextPrayerUpdate() async {
    final PrayerModel? prayerModel = await PrayerProxy().getTodayPrayer();
    if (prayerModel == null) return;

    final prayers = [
      (name: 'fajr', time: prayerModel.fajr, next: 'dhuhr'),
      (name: 'dhuhr', time: prayerModel.dhuhr, next: 'asr'),
      (name: 'asr', time: prayerModel.asr, next: 'maghrib'),
      (name: 'maghrib', time: prayerModel.maghrib, next: 'isha'),
      (name: 'isha', time: prayerModel.isha, next: 'fajr'),
    ];

    final now = DateTime.now();

    for (final prayer in prayers) {
      final prayerDateTime = _parsePrayerTime(prayer.time, now);
      if (prayerDateTime == null) {
        debugPrint('Skipping ${prayer.name}: invalid time "${prayer.time}"');
        continue;
      }

      final widgetUpdateTime = prayerDateTime.add(const Duration(minutes: 5));
      final delay = widgetUpdateTime.difference(now);

      if (delay.isNegative) {
        debugPrint(
          'Skipping ${prayer.name}: already passed today (${prayer.time})',
        );
        continue;
      }

      await Workmanager().registerOneOffTask(
        'widget_next_prayer_${prayer.name}',
        'nextPrayerTaskUpdate',
        initialDelay: delay,
        inputData: {'prayerName': prayer.name, 'nextPrayerName': prayer.next},
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );

      debugPrint(
        'Scheduled next prayer update for ${prayer.name} in ${delay.inMinutes} minutes',
      );
    }
  }

  static DateTime? _parsePrayerTime(String time, DateTime reference) {
    final parts = time.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return DateTime(
      reference.year,
      reference.month,
      reference.day,
      hour,
      minute,
    );
  }
}
