import 'dart:io';
import 'dart:ui' show DartPluginRegistrant, PlatformDispatcher;

import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/dzikir_period_model.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/prayer_log_proxy.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/timezone.dart' as tz;

/// Runs in a background isolate when a notification action that does not
/// open the app is tapped, so it must be a top-level entry point.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  /// Needed to cancel the missed prayer reminder from this isolate.
  await NotificationHelper().init();
  await NotificationHelper.handleResponse(response);
}

class NotificationHelper {
  /// Action on the adhan notification that marks the prayer as done.
  static const String actionMarkDone = 'mark_done';

  static const String keyMissedReminder = 'isMissedReminderEnabled';

  /// Ids of the missed prayer reminders, after the adhan (1-5) and the
  /// before-adhan reminders (11-55).
  static const int _missedReminderIdBase = 100;

  /// A missed prayer reminder comes this long before the prayer's time
  /// ends, but never sooner than [_missedReminderMinDelay] after it began.
  /// Isha has no end, so it comes [_missedReminderLead] after it began.
  static const Duration _missedReminderLead = Duration(minutes: 30);
  static const Duration _missedReminderMinDelay = Duration(minutes: 15);

  static const String keyDzikirReminder = 'isDzikirReminderEnabled';

  /// Ids of the morning and evening dzikir reminders, after the missed
  /// prayer reminders (101-105).
  static const Map<DzikirPeriod, int> _dzikirReminderIds = {
    DzikirPeriod.morning: 201,
    DzikirPeriod.evening: 202,
  };

  /// A dzikir reminder comes this long after its window opens (Fajr or
  /// Asr), leaving time to pray first.
  static const Duration _dzikirReminderDelay = Duration(minutes: 15);

  /// Time each prayer ends, as a [PrayerModel.toJson] key.
  static const Map<String, String> _prayerEnds = {
    'Fajr': 'Sunrise',
    'Dhuhr': 'Asr',
    'Asr': 'Maghrib',
    'Maghrib': 'Isha',
  };

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@drawable/ic_stat_notification',
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      bool? isInitialized = await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: handleResponse,
        onDidReceiveBackgroundNotificationResponse:
            onBackgroundNotificationResponse,
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

  /// Payload of an adhan notification: the day it belongs to and the
  /// prayer, so a late tap still marks the right day.
  static String _adhanPayload(TZDateTime time, String prayer) =>
      '${PrayerLogProxy.dateKey(time)}|$prayer';

  /// Marks the prayer of an adhan notification as done when its action was
  /// tapped. Other taps only open the app.
  static Future<void> handleResponse(NotificationResponse response) async {
    if (response.actionId != actionMarkDone) return;

    final parts = response.payload?.split('|') ?? const [];
    final date = parts.length == 2 ? DateTime.tryParse(parts[0]) : null;
    if (date == null) {
      debugPrint('Unknown adhan payload: ${response.payload}');
      return;
    }

    try {
      await PrayerLogProxy().setDone(date, parts[1], true);
      debugPrint('${parts[1]} on ${parts[0]} marked done from notification');
      await NotificationHelper().updateMissedReminder(date, parts[1], true);
    } catch (e, st) {
      debugPrint('Marking prayer from notification failed: $e\n$st');
    }
  }

  static const String keyPermissionAsked = 'notificationPermissionAsked';

  Future<bool> isPermissionGranted() async {
    if (!Platform.isAndroid) return true;

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation == null) return true;

    return await androidImplementation.areNotificationsEnabled() ?? false;
  }

  /// The onboarding prompt is shown only once; afterwards users manage
  /// notifications from the settings page.
  Future<bool> shouldAskPermission() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(keyPermissionAsked) ?? false) return false;
    return !await isPermissionGranted();
  }

  Future<void> markPermissionAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyPermissionAsked, true);
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

    final l10n = await _loadL10n();
    final prayerLabel = PrayerProxy.prayerLabelOf(l10n, prayerName);

    /// The action is handled in the background, without opening the app.
    final androidNotificationDetails = AndroidNotificationDetails(
      'deenly_notification_channel',
      'Deenly Notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('adhan'),
      playSound: true,
      actions: [
        AndroidNotificationAction(
          actionMarkDone,
          l10n.notificationMarkDone,
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notifId,
      title: l10n.notificationAdhanTitle,
      body: l10n.notificationAdhanBody(prayerLabel),
      notificationDetails: NotificationDetails(
        android: androidNotificationDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      scheduledDate: scheduledTime,
      payload: _adhanPayload(scheduledTime, prayerName),
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

  /// Schedules every enabled notification afresh. Their text is fixed when
  /// scheduled, so this also runs after the app language changes.
  Future<void> rescheduleAll(PrayerModel prayerModel) async {
    await scheduleAllPrayerNotifications(prayerModel);
    await scheduleReminderNotifications(prayerModel);
    await scheduleMissedReminders(prayerModel);
    await scheduleDzikirReminders(prayerModel);
  }

  Future<bool> scheduleReminderNotification({
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
      'deenly_reminder_channel',
      'Deenly Reminder Notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('reminder'),
      playSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // zonedSchedule throws for past dates. When the prayer is less than
    // 10 minutes away, roll the reminder over to the next day instead.
    var reminderTime = scheduledTime.subtract(const Duration(minutes: 10));
    if (reminderTime.isBefore(tz.TZDateTime.now(tz.local))) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }

    final l10n = await _loadL10n();
    final prayerLabel = PrayerProxy.prayerLabelOf(l10n, prayerName);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notifId,
      title: l10n.notificationReminderTitle,
      body: l10n.notificationReminderBody(prayerLabel),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      scheduledDate: reminderTime,
    );

    debugPrint("Reminder scheduled for $prayerName at $reminderTime");
    return true;
  }

  Future<void> scheduleReminderNotifications(PrayerModel prayerModel) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isReminderEnabled') == null ||
        prefs.getBool('isReminderEnabled') == false) {
      return;
    }
    final prayers = [
      (id: 11, name: 'Fajr', time: prayerModel.fajr),
      (id: 22, name: 'Dhuhr', time: prayerModel.dhuhr),
      (id: 33, name: 'Asr', time: prayerModel.asr),
      (id: 44, name: 'Maghrib', time: prayerModel.maghrib),
      (id: 55, name: 'Isha', time: prayerModel.isha),
    ];
    for (final prayer in prayers) {
      await scheduleReminderNotification(
        notifId: prayer.id,
        prayerName: prayer.name,
        scheduledTime: convertToTZ(prayer.time),
      );
    }
  }

  Future<void> disableReminderNotifications(bool isReset) async {
    const reminderIds = [11, 22, 33, 44, 55];

    for (final idx in reminderIds) {
      await flutterLocalNotificationsPlugin.cancel(id: idx);
    }

    if (isReset) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isReminderEnabled', false);
    }
    debugPrint("All reminder notifications disabled");
  }

  static int _missedReminderIdOf(String prayer) =>
      _missedReminderIdBase + PrayerLogProxy.trackedPrayers.indexOf(prayer) + 1;

  /// When to ask whether [prayer] of [prayerModel] (today's times) was
  /// done, or null when its times are unknown.
  static DateTime? missedReminderTime(PrayerModel prayerModel, String prayer) {
    final timings = prayerModel.toJson();
    final start = _todayAt(timings[prayer] as String? ?? '');
    if (start == null) return null;

    final endKey = _prayerEnds[prayer];
    if (endKey == null) return start.add(_missedReminderLead);

    final end = _todayAt(timings[endKey] as String? ?? '');
    if (end == null) return null;
    final earliest = start.add(_missedReminderMinDelay);
    final time = end.subtract(_missedReminderLead);
    return time.isBefore(earliest) ? earliest : time;
  }

  /// Today at [time] ("HH:mm"), or null if unparsable.
  static DateTime? _todayAt(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Schedules today's missed prayer reminders for the prayers not marked
  /// yet, when enabled. Unlike the adhan they are never moved to tomorrow:
  /// the daily task schedules the next day's.
  Future<void> scheduleMissedReminders(PrayerModel prayerModel) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(keyMissedReminder) != true) return;

    final done = await PrayerLogProxy().getDonePrayers(DateTime.now());
    final l10n = await _loadL10n();
    for (final prayer in PrayerLogProxy.trackedPrayers) {
      if (done.contains(prayer)) continue;
      final time = missedReminderTime(prayerModel, prayer);
      if (time == null) continue;
      await _scheduleMissedReminder(prayer, time, l10n);
    }
  }

  /// Keeps the reminder of [prayer] in step with its check: marking it
  /// cancels the reminder, unmarking it today schedules it again.
  Future<void> updateMissedReminder(
    DateTime date,
    String prayer,
    bool isDone,
  ) async {
    if (!DateUtils.isSameDay(date, DateTime.now())) return;

    if (isDone) {
      await cancelNotification(_missedReminderIdOf(prayer));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(keyMissedReminder) != true) return;
    final prayerModel = await PrayerProxy().getTodayPrayer();
    if (prayerModel == null) return;
    final time = missedReminderTime(prayerModel, prayer);
    if (time == null) return;
    await _scheduleMissedReminder(prayer, time, await _loadL10n());
  }

  Future<void> disableMissedReminders() async {
    for (final prayer in PrayerLogProxy.trackedPrayers) {
      await cancelNotification(_missedReminderIdOf(prayer));
    }
  }

  Future<void> _scheduleMissedReminder(
    String prayer,
    DateTime time,
    AppLocalizations l10n,
  ) async {
    if (!time.isAfter(DateTime.now())) return;

    final scheduledTime = tz.TZDateTime.from(time, tz.local);
    final prayerLabel = PrayerProxy.prayerLabelOf(l10n, prayer);

    /// Same action and payload as the adhan, so it marks the prayer too.
    final androidNotificationDetails = AndroidNotificationDetails(
      'deenly_missed_channel',
      'Deenly Missed Prayer Reminders',
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('arabic_oud'),
      playSound: true,
      actions: [
        AndroidNotificationAction(
          actionMarkDone,
          l10n.notificationMarkDone,
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: _missedReminderIdOf(prayer),
      title: l10n.notificationMissedTitle(prayerLabel),
      body: l10n.notificationMissedBody,
      notificationDetails: NotificationDetails(
        android: androidNotificationDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      scheduledDate: scheduledTime,
      payload: _adhanPayload(scheduledTime, prayer),
    );
    debugPrint('Missed reminder scheduled for $prayer at $scheduledTime');
  }

  /// Schedules the morning and evening dzikir reminders, when enabled. One
  /// whose time already passed today is moved to tomorrow.
  Future<void> scheduleDzikirReminders(PrayerModel prayerModel) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(keyDzikirReminder) != true) return;

    final l10n = await _loadL10n();
    for (final period in DzikirPeriod.values) {
      final start = _todayAt(period.startTime(prayerModel));
      final id = _dzikirReminderIds[period];
      if (start == null || id == null) continue;

      var time = start.add(_dzikirReminderDelay);
      if (!time.isAfter(DateTime.now())) {
        time = time.add(const Duration(days: 1));
      }
      await _scheduleDzikirReminder(id, period, time, l10n);
    }
  }

  Future<void> disableDzikirReminders() async {
    for (final id in _dzikirReminderIds.values) {
      await cancelNotification(id);
    }
  }

  Future<void> _scheduleDzikirReminder(
    int id,
    DzikirPeriod period,
    DateTime time,
    AppLocalizations l10n,
  ) async {
    final scheduledTime = tz.TZDateTime.from(time, tz.local);
    final (title, body) = switch (period) {
      DzikirPeriod.morning => (
        l10n.dzikirReminderMorning,
        l10n.notificationDzikirMorningBody,
      ),
      DzikirPeriod.evening => (
        l10n.dzikirReminderEvening,
        l10n.notificationDzikirEveningBody,
      ),
    };

    const androidNotificationDetails = AndroidNotificationDetails(
      'deenly_dzikir_channel',
      'Deenly Dzikir Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidNotificationDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      scheduledDate: scheduledTime,
    );
    debugPrint('Dzikir reminder scheduled for ${period.name} at $time');
  }

  /// Loads the strings for the user's chosen app language, falling back to
  /// the device language and then English. Works without a BuildContext,
  /// so it can be used from the background isolate.
  Future<AppLocalizations> _loadL10n() async {
    final prefs = await SharedPreferences.getInstance();
    final code =
        prefs.getString(LocaleProvider.localeKey) ??
        PlatformDispatcher.instance.locale.languageCode;
    final isSupported = AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == code,
    );
    return lookupAppLocalizations(Locale(isSupported ? code : 'en'));
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
