import 'dart:io';

import 'package:deenly/models/prayer_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
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

  Future<void> scheduleAllPrayerNotifications(PrayerModel prayerModel) async {
    await cancelAllNotifications();

    final prefs = await SharedPreferences.getInstance();

    bool isFajrEnabled = prefs.getBool('isFajrEnabled') ?? false;
    bool isDhuhrEnabled = prefs.getBool('isDhuhrEnabled') ?? false;
    bool isAsrEnabled = prefs.getBool('isAsrEnabled') ?? false;
    bool isMaghribEnabled = prefs.getBool('isMaghribEnabled') ?? false;
    bool isIshaEnabled = prefs.getBool('isIshaEnabled') ?? false;

    if (isFajrEnabled) {
      await schedulePrayerNotification(
        notifId: 1,
        prayerName: 'Fajr',
        scheduledTime: convertToTZ(prayerModel.fajr),
      );
    }

    if (isDhuhrEnabled) {
      await schedulePrayerNotification(
        notifId: 2,
        prayerName: 'Dhuhr',
        scheduledTime: convertToTZ(prayerModel.dhuhr),
      );
    }

    if (isAsrEnabled) {
      await schedulePrayerNotification(
        notifId: 3,
        prayerName: 'Asr',
        scheduledTime: convertToTZ(prayerModel.asr),
      );
    }

    if (isMaghribEnabled) {
      await schedulePrayerNotification(
        notifId: 4,
        prayerName: 'Maghrib',
        scheduledTime: convertToTZ(prayerModel.maghrib),
      );
    }

    if (isIshaEnabled) {
      await schedulePrayerNotification(
        notifId: 5,
        prayerName: 'Isha',
        scheduledTime: convertToTZ(prayerModel.isha),
      );
    }
  }

  TZDateTime convertToTZ(String prayerTime) {
    final parts = prayerTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();

    DateTime prayerDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    final scheduledTime = tz.TZDateTime.from(prayerDateTime, tz.local);
    return scheduledTime;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);

    debugPrint("Notification cancelled for $id");
  }

  Future<void> showNotification({
  required int id,
  required String title,
  required String body,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'error_channel',
    'Error Notifications',
    channelDescription: 'Notifications for background task errors',
    importance: Importance.high,
    priority: Priority.high,
  );

  const notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: notificationDetails,
  );
}
}
