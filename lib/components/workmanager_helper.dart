import 'package:deenly/models/prayer_model.dart';
import 'package:workmanager/workmanager.dart';

const String dailyTaskName = "daily_midnight_notification_task";
const String updateNextPrayerTaskName = "update_next_prayer_task";

class WorkmanagerHelper {
  static Future<void> scheduleDailyNotification() async {
    final now = DateTime.now();

    var scheduledTime = DateTime(now.year, now.month, now.day, 00, 05);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final initialDelay = scheduledTime.difference(now);

    await Workmanager().registerPeriodicTask(
      "dailyNotificationTask",
      dailyTaskName,
      frequency: const Duration(days: 1),
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  static Future<void> scheduleWidgetNextPrayr(PrayerModel prayerModel) async {
    await Workmanager().cancelByTag('nextPrayer_update');

    String capitalize(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    List<String> prayerTimes = [
      prayerModel.fajr,
      prayerModel.dhuhr,
      prayerModel.asr,
      prayerModel.maghrib,
      prayerModel.isha,
    ];

    List<String> prayerNames = ["fajr", "dhuhr", "asr", "maghrib", "isha"];

    for (var prayerTime in prayerTimes) {
      final delay = DateTime.parse(prayerTime).difference(DateTime.now());

      if (delay.isNegative) continue;

      await Workmanager().registerOneOffTask(
        "prayer_${prayerNames[prayerTimes.indexOf(prayerTime)]}",
        updateNextPrayerTaskName,
        tag: 'nextPrayer_update',
        initialDelay: delay,
        inputData: {
          'next_prayer_name': capitalize(prayerNames[prayerTimes.indexOf(prayerTime)]),
        },
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
    }
  }
}
