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
}
