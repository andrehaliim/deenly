import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

const String dailyTaskName = "daily_midnight_notification_task";

class WorkmanagerHelper {
  static Future<void> scheduleDailyNotification() async {
    final now = DateTime.now();

    var scheduledTime = DateTime(now.year, now.month, now.day, 01, 00);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final initialDelay = scheduledTime.difference(now);

    await Workmanager().registerPeriodicTask(
      "dailyNotificationTask",
      'daily_midnight_notification_task',
      frequency: const Duration(days: 1),
      initialDelay: Duration(minutes: 5),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );

    debugPrint("Daily notification scheduled for $scheduledTime");
  }
}
