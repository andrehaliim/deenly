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
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      try {
        final bool? granted = await androidImplementation
            ?.areNotificationsEnabled();
        if (granted == false) return false;
      } catch (_) {}
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

    final prayers = [
      (
        id: 1,
        name: 'Fajr',
        enabled: prefs.getBool('isFajrEnabled') ?? false,
        time: prayerModel.fajr,
      ),
      (
        id: 2,
        name: 'Dhuhr',
        enabled: prefs.getBool('isDhuhrEnabled') ?? false,
        time: prayerModel.dhuhr,
      ),
      (
        id: 3,
        name: 'Asr',
        enabled: prefs.getBool('isAsrEnabled') ?? false,
        time: prayerModel.asr,
      ),
      (
        id: 4,
        name: 'Maghrib',
        enabled: prefs.getBool('isMaghribEnabled') ?? false,
        time: prayerModel.maghrib,
      ),
      (
        id: 5,
        name: 'Isha',
        enabled: prefs.getBool('isIshaEnabled') ?? false,
        time: prayerModel.isha,
      ),
    ];

    for (final prayer in prayers) {
      if (!prayer.enabled) continue;

      await schedulePrayerNotification(
        notifId: prayer.id,
        prayerName: prayer.name,
        scheduledTime: convertToTZ(prayer.time),
      );
    }
  }

  TZDateTime convertToTZ(String prayerTime) {
    final parts = prayerTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

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
    final androidDetails = AndroidNotificationDetails(
      'error_channel',
      'Error Notifications',
      channelDescription: 'Notifications for background task errors',
      importance: Importance.high,
      priority: Priority.high,

      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Tap to view',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> getPendingNotifications() async {
    final List<PendingNotificationRequest> pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    if (pending.isEmpty) {
      debugPrint('No scheduled notifications');
      return;
    }

    for (var notification in pending) {
      debugPrint('ID: ${notification.id}');
      debugPrint('Title: ${notification.title}');
      debugPrint('Body: ${notification.body}');
    }
  }
}
