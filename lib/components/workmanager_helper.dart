import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:workmanager/workmanager.dart';

const String dailyTaskName = "daily_refresh_prayer";
const String nextPrayerTaskName = "next_prayer_update";

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

  static Future<void> scheduleDailyNextPrayerUpdate() async {
    String? nextPrayerName;
    final now = DateTime.now();
    final prayerModel = await PrayerProxy().getTodayPrayer();
    if (prayerModel == null) {
      return;
    }
    final data = {
      "fajr": prayerModel.fajr,
      "dhuhr": prayerModel.dhuhr,
      "asr": prayerModel.asr,
      "maghrib": prayerModel.maghrib,
      "isha": prayerModel.isha,
    };

    for (var prayer in data.entries) {
      final prayerTime = prayer.value;
      final prayerName = prayer.key;
      final hour = int.parse(prayerTime.split(":")[0]);
      final minute = int.parse(prayerTime.split(":")[1]);
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (prayerDateTime.isBefore(now)) {
        continue;
      }

      if (nextPrayerName == null) {
        nextPrayerName = prayerName;
        await WidgetHelper().updateWidgetNextPrayer(prayerName);
      }

      final initialDelays = prayerDateTime.difference(now);

      await Workmanager().registerOneOffTask(
        "nextPrayer_${prayerName}_${now.month}_${now.day}",
        nextPrayerTaskName,
        initialDelay: initialDelays,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        inputData: {"prayerName": prayerName},
      );
    }
  }
}
