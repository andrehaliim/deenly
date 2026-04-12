import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

class NotificationHelper {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      bool? isInitialized = await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null) {
            debugPrint("Notification payload: ${details.payload}");
          }
        },
      );

      if (isInitialized == null) {
        debugPrint("Notification Helper failed to initialize");
        return;
      } else if (!isInitialized) {
        debugPrint("Notification Helper failed to initialize");
        return;
      }

      debugPrint("Notification Helper initialized successfully");
    } catch (e) {
      debugPrint(
        "Notification Helper failed to initialize (Normal for tests): $e",
      );
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }
    }
    return false;
  }

  Future<void> showHelloNotification() async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'deenly_notification_channel',
      'Deenly Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 1,
      title: 'sss',
      body: 'Hello!',
      notificationDetails: notificationDetails,
      payload: 'hello_payload',
    );
  }

  Future<void> showDailyMidnightNotification(String date) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'daily_midnight_channel',
      'Daily Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 100,
      title: 'Daily Notification',
      body: "its midnight at $date (now)",
      notificationDetails: notificationDetails,
    );
  }

  Future<bool> schedulePrayerNotification({
    required int notifId,
    required String prayerName,
    required TZDateTime scheduledTime,
  }) async {
    bool isGranted = await requestPermission();
    if (!isGranted) {
      return false;
    }

    const androidNotificationDetails = AndroidNotificationDetails(
      'deenly_notification_channel',
      'Deenly Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notifId,
      title: 'Adhan Reminder',
      body: 'It is time for $prayerName prayer',
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      scheduledDate: scheduledTime,
    );

    debugPrint("Notification scheduled for $prayerName at $scheduledTime");
    return true;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);

    debugPrint("Notification cancelled for $id");
  }
}
