import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/prayer_sync_helper.dart';
import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class DrawerProvider extends ChangeNotifier {
  /// Prayers shown in the drawer, in order. The notification id of each
  /// prayer is its index + 1.
  static const List<String> prayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  final SharedPreferences prefs;

  final Map<String, bool> _enabled = {};
  final Map<String, int> _adjustments = {};

  bool _isPrayerReminderEnabled = false;
  bool get isPrayerReminderEnabled => _isPrayerReminderEnabled;

  bool _isDzikirReminderEnabled = false;
  bool get isDzikirReminderEnabled => _isDzikirReminderEnabled;

  bool _isHolidayReminderEnabled = false;
  bool get isHolidayReminderEnabled => _isHolidayReminderEnabled;

  bool _isSunnahFastReminderEnabled = false;
  bool get isSunnahFastReminderEnabled => _isSunnahFastReminderEnabled;

  bool _isMondayThursdayReminderEnabled = false;
  bool get isMondayThursdayReminderEnabled => _isMondayThursdayReminderEnabled;

  DrawerProvider(this.prefs, Map<String, int> adjustments) {
    _adjustments.addAll(adjustments);
    _loadSettings();
  }

  static int notificationIdOf(String prayer) => prayers.indexOf(prayer) + 1;

  static String _enabledKey(String prayer) => 'is${prayer}Enabled';

  bool isPrayerEnabled(String prayer) => _enabled[prayer] ?? false;

  /// Saved (already applied) adjustment of [prayer], in minutes.
  int adjustmentOf(String prayer) => _adjustments[prayer] ?? 0;

  void _loadSettings() {
    for (final prayer in prayers) {
      _enabled[prayer] = prefs.getBool(_enabledKey(prayer)) ?? false;
    }

    _isPrayerReminderEnabled =
        prefs.getBool(NotificationHelper.keyPrayerReminder) ?? false;
    _isDzikirReminderEnabled =
        prefs.getBool(NotificationHelper.keyDzikirReminder) ?? false;
    _isHolidayReminderEnabled =
        prefs.getBool(NotificationHelper.keyHolidayReminder) ?? false;
    _isSunnahFastReminderEnabled =
        prefs.getBool(NotificationHelper.keySunnahFastReminder) ?? false;
    _isMondayThursdayReminderEnabled =
        prefs.getBool(NotificationHelper.keyMondayThursdayReminder) ?? false;
  }

  Future<void> togglePrayer(String prayer, bool value) async {
    _enabled[prayer] = value;
    await prefs.setBool(_enabledKey(prayer), value);
    WidgetHelper().updateWidgetNotification(prayer.toLowerCase(), value);
    notifyListeners();
  }

  /// Turns on the adhan, prayer reminder, dzikir and calendar
  /// notifications. They are scheduled once the home page loads the prayer
  /// times.
  Future<void> enableAllNotifications() async {
    for (final prayer in prayers) {
      await togglePrayer(prayer, true);
    }
    _isPrayerReminderEnabled = true;
    await prefs.setBool(NotificationHelper.keyPrayerReminder, true);
    _isDzikirReminderEnabled = true;
    await prefs.setBool(NotificationHelper.keyDzikirReminder, true);
    _isHolidayReminderEnabled = true;
    await prefs.setBool(NotificationHelper.keyHolidayReminder, true);
    _isSunnahFastReminderEnabled = true;
    await prefs.setBool(NotificationHelper.keySunnahFastReminder, true);
    _isMondayThursdayReminderEnabled = true;
    await prefs.setBool(NotificationHelper.keyMondayThursdayReminder, true);
    notifyListeners();
  }

  Future<void> toggleHolidayReminder(bool value) async {
    _isHolidayReminderEnabled = value;
    await _saveCalendarReminder(NotificationHelper.keyHolidayReminder, value);
  }

  Future<void> toggleSunnahFastReminder(bool value) async {
    _isSunnahFastReminderEnabled = value;
    await _saveCalendarReminder(
      NotificationHelper.keySunnahFastReminder,
      value,
    );
  }

  Future<void> toggleMondayThursdayReminder(bool value) async {
    _isMondayThursdayReminderEnabled = value;
    await _saveCalendarReminder(
      NotificationHelper.keyMondayThursdayReminder,
      value,
    );
  }

  /// Calendar reminders don't need prayer times, so they always schedule.
  Future<void> _saveCalendarReminder(String key, bool value) async {
    notifyListeners();
    await prefs.setBool(key, value);
    await NotificationHelper().scheduleCalendarReminders();
    await NotificationHelper().logNotificationToggle(key, value);
  }

  /// Turns the adhan notification of [prayer] on or off and schedules it.
  /// Returns false, leaving it off, when it could not be scheduled.
  Future<bool> setPrayerNotification(String prayer, bool value) async {
    await togglePrayer(prayer, value);
    final notifId = notificationIdOf(prayer);
    var success = true;
    if (!value) {
      await NotificationHelper().cancelNotification(notifId);
    } else {
      success = await _schedulePrayerNotification(prayer, notifId);
      if (!success) await togglePrayer(prayer, false);
    }

    await NotificationHelper().logNotificationToggle(
      _enabledKey(prayer),
      value,
    );
    return success;
  }

  Future<bool> _schedulePrayerNotification(String prayer, int notifId) async {
    final PrayerModel? prayerModel = await PrayerProxy().getTodayPrayer();
    if (prayerModel == null) return false;

    /// toJson() keys match the prayer names ('Fajr', 'Dhuhr', ...).
    final parts = (prayerModel.toJson()[prayer] as String).split(':');
    final now = DateTime.now();
    var prayerDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    if (prayerDateTime.isBefore(now)) {
      prayerDateTime = prayerDateTime.add(const Duration(days: 1));
    }

    final isScheduled = await NotificationHelper().schedulePrayerNotification(
      notifId: notifId,
      prayerName: prayer,
      scheduledTime: tz.TZDateTime.from(prayerDateTime, tz.local),
    );
    if (!isScheduled) {
      debugPrint('Notification failed to schedule for $prayer');
    }
    return isScheduled;
  }

  /// Applies [adjustments] (minutes per prayer) to the stored prayer
  /// times. These become the saved values returned by [adjustmentOf].
  Future<void> saveAdjustments(Map<String, int> adjustments) async {
    await PrayerProxy().saveAdjustments(adjustments);
    _adjustments.addAll(adjustments);
    notifyListeners();
  }

  /// Calculation method chosen by the user; null means automatic.
  int? get prayerMethod => prefs.getInt(PrayerSyncHelper.keyMethod);

  /// Asr school chosen by the user; null means automatic.
  int? get prayerSchool => prefs.getInt(PrayerSyncHelper.keySchool);

  /// Country the automatic method and school follow, if known.
  String? get prayerCountry => prefs.getString(PrayerSyncHelper.keyCountry);

  /// Saves the choice (null for automatic) and refetches the prayer times.
  /// The choice stays saved even when the fetch fails.
  Future<void> setPrayerCalculation({
    required int? method,
    required int? school,
  }) async {
    try {
      await PrayerSyncHelper().setCalculation(method: method, school: school);
    } finally {
      notifyListeners();
    }
  }

  /// Turns the prayer reminders before each prayer and sunrise on or off.
  /// Returns false, leaving them off, when there are no prayer times to
  /// use.
  Future<bool> togglePrayerReminder(bool value) async {
    _isPrayerReminderEnabled = value;
    await prefs.setBool(NotificationHelper.keyPrayerReminder, value);

    if (!value) {
      await NotificationHelper().disablePrayerReminders();
    } else {
      final PrayerModel? prayerModel = await PrayerProxy().getTodayPrayer();
      if (prayerModel == null) {
        _isPrayerReminderEnabled = false;
        await prefs.setBool(NotificationHelper.keyPrayerReminder, false);
        notifyListeners();
        return false;
      }
      await NotificationHelper().schedulePrayerReminders(prayerModel);
    }

    await NotificationHelper().logNotificationToggle(
      NotificationHelper.keyPrayerReminder,
      value,
    );
    notifyListeners();
    return true;
  }

  /// Turns the morning and evening dzikir reminders on or off. Returns
  /// false, leaving them off, when there are no prayer times to use.
  Future<bool> toggleDzikirReminder(bool value) async {
    _isDzikirReminderEnabled = value;
    await prefs.setBool(NotificationHelper.keyDzikirReminder, value);

    if (!value) {
      await NotificationHelper().disableDzikirReminders();
    } else {
      final PrayerModel? prayerModel = await PrayerProxy().getTodayPrayer();
      if (prayerModel == null) {
        _isDzikirReminderEnabled = false;
        await prefs.setBool(NotificationHelper.keyDzikirReminder, false);
        notifyListeners();
        return false;
      }
      await NotificationHelper().scheduleDzikirReminders(prayerModel);
    }

    await NotificationHelper().logNotificationToggle(
      NotificationHelper.keyDzikirReminder,
      value,
    );
    notifyListeners();
    return true;
  }
}
