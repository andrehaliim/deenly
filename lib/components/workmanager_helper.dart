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

    final entries = data.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final prayer = entries[i];
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

      // Determine the prayer that follows this one to be shown next
      String followingPrayerName;
      if (i < entries.length - 1) {
        followingPrayerName = entries[i + 1].key;
      } else {
        followingPrayerName = entries[0].key; // After Isha, next is Fajr
      }

      await Workmanager().registerOneOffTask(
        "nextPrayer_${prayerName}_${now.month}_${now.day}",
        nextPrayerTaskName,
        initialDelay: initialDelays,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        inputData: {"prayerName": followingPrayerName},
      );
    }

    if (nextPrayerName == null) {
      await WidgetHelper().updateWidgetNextPrayer("fajr");
    }
  }
}
