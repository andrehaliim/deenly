import 'package:workmanager/workmanager.dart';

const String dailyTaskName = "daily_midnight_notification_task";

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
}
