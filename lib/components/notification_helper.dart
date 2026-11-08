import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:deenly/components/hijri_calendar_helper.dart';
import 'package:deenly/components/hijri_format.dart';
import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/dzikir_period_model.dart';
import 'package:deenly/models/islamic_event_model.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/prayer_log_proxy.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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

  /// Needed to cancel the prayer reminder from this isolate.
  await NotificationHelper().init();
  await NotificationHelper.handleResponse(response);
}

typedef _PrayerReminder = ({
  int id,
  String time,
  String? asks,
  bool isAskedDayBefore,
});

class NotificationHelper {
  /// Action on the adhan notification that marks the prayer as done.
  static const String actionMarkDone = 'mark_done';

  static const String keyPrayerReminder = 'isPrayerReminderEnabled';

  /// A prayer reminder comes this long before its time.
  static const Duration _prayerReminderLead = Duration(minutes: 10);

  /// Prayer reminders, with ids after the adhan (1-5). Each comes before
  /// [time] (a [PrayerModel.toJson] key) and asks whether [asks], the
  /// prayer whose time it ends, was done. Isha lasts until Fajr, so it is
  /// asked the next morning. Fajr ends at sunrise, hours before Dhuhr, so
  /// the Dhuhr one only says to get ready.
  static const List<_PrayerReminder> _prayerReminders = [
    (id: 11, time: 'Fajr', asks: 'Isha', isAskedDayBefore: true),
    (id: 12, time: 'Sunrise', asks: 'Fajr', isAskedDayBefore: false),
    (id: 13, time: 'Dhuhr', asks: null, isAskedDayBefore: false),
    (id: 14, time: 'Asr', asks: 'Dhuhr', isAskedDayBefore: false),
    (id: 15, time: 'Maghrib', asks: 'Asr', isAskedDayBefore: false),
    (id: 16, time: 'Isha', asks: 'Maghrib', isAskedDayBefore: false),
  ];

  static const String keyDzikirReminder = 'isDzikirReminderEnabled';

  /// Ids of the morning and evening dzikir reminders, after the prayer
  /// reminders (11-16).
  static const Map<DzikirPeriod, int> _dzikirReminderIds = {
    DzikirPeriod.morning: 201,
    DzikirPeriod.evening: 202,
  };

  /// A dzikir reminder comes this long after its window opens (Fajr or
  /// Asr), leaving time to pray first.
  static const Duration _dzikirReminderDelay = Duration(minutes: 15);

  static const String keyHolidayReminder = 'isHolidayReminderEnabled';
  static const String keySunnahFastReminder = 'isSunnahFastReminderEnabled';
  static const String keyMondayThursdayReminder =
      'isMondayThursdayReminderEnabled';

  /// Calendar reminders are scheduled this many evenings ahead, so they
  /// keep coming when the daily task runs late. Ids follow the dzikir
  /// reminders (301 onwards).
  static const int _calendarReminderDays = 7;
  static const int _calendarReminderIdBase = 301;

  /// Hour of the evening before the event that its reminder comes.
  static const int _calendarReminderHour = 20;

  /// Ramadan, Shawwal and Dhul Hijjah start on the isbat, so their dates
  /// are an estimate until the official start is in the app config.
  static const Set<int> _isbatMonths = {9, 10, 12};

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
  static String _adhanPayload(DateTime time, String prayer) =>
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
      await NotificationHelper().updatePrayerReminder(date, parts[1]);
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

  /// Android 12 and below allow notifications without a runtime prompt, so
  /// the onboarding step is skipped there. On a fresh install the default
  /// notifications are turned on instead, once.
  Future<bool> shouldEnableByDefault() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(keyPermissionAsked) ?? false) return false;
    if (prefs.containsKey(keyPrayerReminder)) return false;
    return await isPermissionGranted();
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

  /// Exact alarms need the "Alarms & reminders" access, which Android 14+
  /// denies by default. Android 11 and below always allow them.
  Future<bool> canScheduleExact() async {
    if (!Platform.isAndroid) return true;
    try {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.canScheduleExactNotifications() ??
          true;
    } catch (e) {
      debugPrint('Checking exact alarm access failed: $e');
      return false;
    }
  }

  /// Opens the system "Alarms & reminders" screen for this app.
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.requestExactAlarmsPermission() ??
          false;
    } catch (e) {
      debugPrint('Requesting exact alarm access failed: $e');
      return false;
    }
  }

  /// Without exact alarm access a schedule must be inexact, otherwise
  /// zonedSchedule throws and the notification is never set. Inexact ones
  /// may come a few minutes late while the device dozes.
  Future<AndroidScheduleMode> _scheduleMode() async {
    return await canScheduleExact()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
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
      androidScheduleMode: await _scheduleMode(),
      scheduledDate: scheduledTime,
      payload: _adhanPayload(scheduledTime, prayerName),
    );
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
    await schedulePrayerReminders(prayerModel);
    await scheduleDzikirReminders(prayerModel);
    await scheduleCalendarReminders();
    await logNotificationStatus('reschedule all');
  }

  /// Schedules the next prayer reminder of each time, when enabled. One
  /// whose time already passed today is moved to tomorrow.
  Future<void> schedulePrayerReminders(PrayerModel prayerModel) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(keyPrayerReminder) != true) return;

    final l10n = await _loadL10n();
    for (final reminder in _prayerReminders) {
      await _schedulePrayerReminder(reminder, prayerModel, l10n);
    }
  }

  /// Keeps the reminder that asks about [prayer] on [date] in step with
  /// its check: marking it cancels the reminder, unmarking schedules it
  /// again.
  Future<void> updatePrayerReminder(DateTime date, String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(keyPrayerReminder) != true) return;

    final reminder = _prayerReminders
        .where((reminder) => reminder.asks == prayer)
        .firstOrNull;
    if (reminder == null) return;
    final prayerModel = await PrayerProxy().getTodayPrayer();
    if (prayerModel == null) return;
    final time = _nextPrayerReminderTime(reminder, prayerModel);
    if (time == null) return;
    if (!DateUtils.isSameDay(_askedDayOf(reminder, time), date)) return;

    await _schedulePrayerReminder(reminder, prayerModel, await _loadL10n());
  }

  Future<void> disablePrayerReminders() async {
    for (final reminder in _prayerReminders) {
      await cancelNotification(reminder.id);
    }
  }

  /// Next time [reminder] comes, from today's prayer times, or null when
  /// its time is unknown.
  static DateTime? _nextPrayerReminderTime(
    _PrayerReminder reminder,
    PrayerModel prayerModel,
  ) {
    final start = _todayAt(
      prayerModel.toJson()[reminder.time] as String? ?? '',
    );
    if (start == null) return null;
    final time = start.subtract(_prayerReminderLead);
    return time.isAfter(DateTime.now())
        ? time
        : time.add(const Duration(days: 1));
  }

  /// Day of the prayer [reminder] asks about when it comes at [time].
  static DateTime _askedDayOf(_PrayerReminder reminder, DateTime time) =>
      DateTime(
        time.year,
        time.month,
        time.day - (reminder.isAskedDayBefore ? 1 : 0),
      );

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

  /// Schedules the next [reminder]. Once the prayer it asks about is
  /// marked done, it only says to get ready, and the sunrise one, with no
  /// prayer to get ready for, is cancelled.
  Future<void> _schedulePrayerReminder(
    _PrayerReminder reminder,
    PrayerModel prayerModel,
    AppLocalizations l10n,
  ) async {
    final time = _nextPrayerReminderTime(reminder, prayerModel);
    if (time == null) return;

    var asks = reminder.asks;
    final askedDay = _askedDayOf(reminder, time);
    if (asks != null) {
      final done = await PrayerLogProxy().getDonePrayers(askedDay);
      if (done.contains(asks)) asks = null;
    }
    if (asks == null && reminder.time == 'Sunrise') {
      await cancelNotification(reminder.id);
      return;
    }

    final title = reminder.time == 'Sunrise'
        ? l10n.notificationSunriseReminderTitle
        : l10n.notificationPrayerReminderTitle(
            PrayerProxy.prayerLabelOf(l10n, reminder.time),
          );
    final body = asks == null
        ? l10n.notificationPrayerReminderReady
        : l10n.notificationPrayerReminderAsk(
            PrayerProxy.prayerLabelOf(l10n, asks),
          );

    /// Same action and payload as the adhan, so it marks the asked prayer.
    final androidNotificationDetails = AndroidNotificationDetails(
      'deenly_reminder_channel',
      'Deenly Reminder Notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('reminder'),
      playSound: true,
      actions: [
        if (asks != null)
          AndroidNotificationAction(
            actionMarkDone,
            l10n.notificationMarkDone,
            showsUserInterface: false,
            cancelNotification: true,
          ),
      ],
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: reminder.id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidNotificationDetails,
      ),
      androidScheduleMode: await _scheduleMode(),
      scheduledDate: tz.TZDateTime.from(time, tz.local),
      payload: asks == null ? null : _adhanPayload(askedDay, asks),
    );
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
      androidScheduleMode: await _scheduleMode(),
      scheduledDate: scheduledTime,
    );
  }

  /// Runs the calendar scheduling one call at a time, so a call that reads
  /// newer calendar data (e.g. right after the isbat dates arrive) is never
  /// overwritten by an older one that finishes later.
  static Future<void> _calendarScheduling = Future.value();

  /// Schedules a reminder on each of the next evenings before a holiday
  /// or sunnah fast, for the kinds that are enabled. Several events on the
  /// same day share one notification.
  Future<void> scheduleCalendarReminders() {
    final scheduling = _calendarScheduling.then(
      (_) => _scheduleCalendarReminders(),
    );
    _calendarScheduling = scheduling.catchError((Object _) {});
    return scheduling;
  }

  Future<void> _scheduleCalendarReminders() async {
    await disableCalendarReminders();

    final prefs = await SharedPreferences.getInstance();
    final isHolidayOn = prefs.getBool(keyHolidayReminder) == true;
    final isSunnahOn = prefs.getBool(keySunnahFastReminder) == true;
    final isMondayThursdayOn = prefs.getBool(keyMondayThursdayReminder) == true;
    if (!isHolidayOn && !isSunnahOn && !isMondayThursdayOn) return;

    final calendar = await HijriCalendarHelper.loadSaved();
    final l10n = await _loadL10n();
    final now = DateTime.now();
    for (var i = 0; i < _calendarReminderDays; i++) {
      final time = DateTime(
        now.year,
        now.month,
        now.day + i,
        _calendarReminderHour,
      );
      if (!time.isAfter(now)) continue;

      final day = calendar.dayOf(DateTime(time.year, time.month, time.day + 1));
      final events = day.events.where((event) {
        if (!event.startsOn(day.hijri)) return false;
        return (isHolidayOn && event.isHoliday) ||
            (isSunnahOn && event.fasting == FastingType.sunnah);
      }).toList();
      final isMondayThursday = isMondayThursdayOn && day.isMondayThursdayFast;

      final names = [
        for (final event in events) event.name(l10n.localeName),
        if (isMondayThursday)
          day.date.weekday == DateTime.monday
              ? l10n.calendarReminderMondayFast
              : l10n.calendarReminderThursdayFast,
      ];
      if (names.isEmpty) continue;

      final isFasting =
          isMondayThursday ||
          events.any((event) => event.fasting == FastingType.sunnah);
      final isEstimate =
          events.any((event) => _isbatMonths.contains(event.month)) &&
          !calendar.isOfficialMonth(day.hijri);
      final body = [
        isFasting
            ? l10n.calendarReminderFastingBody
            : l10n.calendarReminderHolidayBody(
                HijriFormat.full(l10n, day.hijri),
              ),
        if (isEstimate) l10n.calendarReminderEstimate,
      ].join(' ');

      await _scheduleCalendarReminder(
        _calendarReminderIdBase + i,
        l10n.calendarReminderTitle(names.join(', ')),
        body,
        time,
      );
    }
  }

  Future<void> disableCalendarReminders() async {
    for (var i = 0; i < _calendarReminderDays; i++) {
      await cancelNotification(_calendarReminderIdBase + i);
    }
  }

  Future<void> _scheduleCalendarReminder(
    int id,
    String title,
    String body,
    DateTime time,
  ) async {
    final androidNotificationDetails = AndroidNotificationDetails(
      'deenly_calendar_channel',
      'Deenly Calendar Reminders',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidNotificationDetails,
      ),
      androidScheduleMode: await _scheduleMode(),
      scheduledDate: tz.TZDateTime.from(time, tz.local),
    );
  }

  /// Loads the strings for the user's chosen app language, falling back to
  /// the app's default language. Works without a BuildContext, so it can be
  /// used from the background isolate.
  Future<AppLocalizations> _loadL10n() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultCode = LocaleProvider.defaultLocale.languageCode;
    final code = prefs.getString(LocaleProvider.localeKey) ?? defaultCode;
    final isSupported = AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == code,
    );
    return lookupAppLocalizations(Locale(isSupported ? code : defaultCode));
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

  static List<int> get _prayerReminderIds => [
    for (final reminder in _prayerReminders) reminder.id,
  ];

  static List<int> get _calendarReminderIds => [
    for (var i = 0; i < _calendarReminderDays; i++) _calendarReminderIdBase + i,
  ];

  /// Name and notification ids of the kind each toggle's [key] controls.
  static ({String name, List<int> ids})? _toggleKindOf(String key) {
    for (final (i, prayer) in PrayerLogProxy.trackedPrayers.indexed) {
      if (key == 'is${prayer}Enabled') {
        return (name: 'Adhan $prayer', ids: [i + 1]);
      }
    }
    return switch (key) {
      keyPrayerReminder => (name: 'Prayer reminder', ids: _prayerReminderIds),
      keyDzikirReminder => (
        name: 'Dzikir',
        ids: _dzikirReminderIds.values.toList(),
      ),
      keyHolidayReminder => (
        name: 'Calendar holiday',
        ids: _calendarReminderIds,
      ),
      keySunnahFastReminder => (
        name: 'Calendar sunnah fast',
        ids: _calendarReminderIds,
      ),
      keyMondayThursdayReminder => (
        name: 'Calendar monday-thursday fast',
        ids: _calendarReminderIds,
      ),
      _ => null,
    };
  }

  /// Logs, in debug builds only, the notification kind a toggle changed
  /// and its ids: the ones now pending when turned on, else all of them.
  Future<void> logNotificationToggle(String key, bool value) async {
    if (!kDebugMode) return;
    final kind = _toggleKindOf(key);
    if (kind == null) return;

    var ids = kind.ids;
    if (value) {
      final pending = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      final pendingIds = {for (final request in pending) request.id};
      ids = ids.where(pendingIds.contains).toList();
    }
    final action = value ? 'ON, scheduled' : 'OFF, cancelled';
    debugPrint(
      '[Notif] ${kind.name} $action id: '
      '${ids.isEmpty ? '-' : ids.join(', ')}',
    );
  }

  /// Logs, in debug builds only, every notification kind with its toggle
  /// and its pending ids, then each pending notification. A kind that is
  /// off but still pending, or on but never scheduled, is flagged.
  Future<void> logNotificationStatus(String reason) async {
    if (!kDebugMode) return;

    final prefs = await SharedPreferences.getInstance();
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    final pendingIds = {for (final request in pending) request.id};

    bool? isPermitted;
    if (Platform.isAndroid) {
      isPermitted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
    }

    bool isOn(String key) => prefs.getBool(key) == true;
    final isCalendarOn =
        isOn(keyHolidayReminder) ||
        isOn(keySunnahFastReminder) ||
        isOn(keyMondayThursdayReminder);

    /// Calendar reminders may rightly have nothing pending (no event is
    /// near), so only the other kinds are flagged when on without anything
    /// pending. Only the sunrise prayer reminder is skipped once marked, so
    /// the others are always pending.
    final kinds = [
      for (final (i, prayer) in PrayerLogProxy.trackedPrayers.indexed)
        (
          name: 'Adhan $prayer',
          isOn: isOn('is${prayer}Enabled'),
          ids: [i + 1],
          isAlwaysPending: true,
        ),
      (
        name: 'Prayer reminder',
        isOn: isOn(keyPrayerReminder),
        ids: _prayerReminderIds,
        isAlwaysPending: true,
      ),
      (
        name: 'Dzikir',
        isOn: isOn(keyDzikirReminder),
        ids: _dzikirReminderIds.values.toList(),
        isAlwaysPending: true,
      ),
      (
        name: 'Calendar',
        isOn: isCalendarOn,
        ids: _calendarReminderIds,
        isAlwaysPending: false,
      ),
    ];

    final lines = [
      '===== Notifications ($reason) =====',
      'Permission: ${isPermitted ?? 'unknown'}, pending: ${pending.length}',
      if (isCalendarOn)
        'Calendar: holiday ${isOn(keyHolidayReminder)}, '
            'sunnah ${isOn(keySunnahFastReminder)}, '
            'monday-thursday ${isOn(keyMondayThursdayReminder)}',
    ];
    final knownIds = <int>{};
    for (final kind in kinds) {
      knownIds.addAll(kind.ids);
      final ids = kind.ids.where(pendingIds.contains).toList();
      final warning = switch ((kind.isOn, ids.isEmpty)) {
        (false, false) => '  <-- OFF but pending',
        (true, true) when kind.isAlwaysPending => '  <-- ON but not pending',
        _ => '',
      };
      final status = kind.isOn ? 'ON ' : 'OFF';
      lines.add(
        '${kind.name.padRight(14)} $status pending: '
        '${ids.isEmpty ? '-' : ids.join(', ')}$warning',
      );
    }
    final otherIds = pendingIds.difference(knownIds);
    if (otherIds.isNotEmpty) lines.add('Other pending: ${otherIds.join(', ')}');

    final sorted = pending.toList()..sort((a, b) => a.id.compareTo(b.id));
    for (final request in sorted) {
      lines.add('#${request.id} ${request.title} | ${request.body}');
    }
    lines.add('=' * 40);

    for (final line in lines) {
      debugPrint('[Notif] $line');
    }
  }
}
