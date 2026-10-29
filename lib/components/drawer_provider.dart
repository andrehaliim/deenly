import 'package:deenly/components/notification_helper.dart';
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

  bool _isNotificationExpanded = true;
  bool get isNotificationExpanded => _isNotificationExpanded;

  bool _isAdjustmentExpanded = true;
  bool get isAdjustmentExpanded => _isAdjustmentExpanded;

  bool _isReminderEnabled = false;
  bool get isReminderEnabled => _isReminderEnabled;

  bool _isMissedReminderEnabled = false;
  bool get isMissedReminderEnabled => _isMissedReminderEnabled;

  bool _isDzikirReminderEnabled = false;
  bool get isDzikirReminderEnabled => _isDzikirReminderEnabled;

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

    _isReminderEnabled = prefs.getBool('isReminderEnabled') ?? false;
    _isMissedReminderEnabled =
        prefs.getBool(NotificationHelper.keyMissedReminder) ?? false;
    _isDzikirReminderEnabled =
        prefs.getBool(NotificationHelper.keyDzikirReminder) ?? false;
  }

  Future<void> togglePrayer(String prayer, bool value) async {
    _enabled[prayer] = value;
    await prefs.setBool(_enabledKey(prayer), value);
    WidgetHelper().updateWidgetNotification(prayer.toLowerCase(), value);
    notifyListeners();
  }

  /// Turns on the adhan, before-prayer, after-prayer and dzikir
  /// notifications. They are scheduled once the home page loads the prayer
  /// times.
  Future<void> enableAllNotifications() async {
    for (final prayer in prayers) {
      await togglePrayer(prayer, true);
    }
    _isReminderEnabled = true;
    await prefs.setBool('isReminderEnabled', true);
    _isMissedReminderEnabled = true;
    await prefs.setBool(NotificationHelper.keyMissedReminder, true);
    _isDzikirReminderEnabled = true;
    await prefs.setBool(NotificationHelper.keyDzikirReminder, true);
    notifyListeners();
  }

  /// Turns the adhan notification of [prayer] on or off and schedules it.
  /// Returns false, leaving it off, when it could not be scheduled.
  Future<bool> setPrayerNotification(String prayer, bool value) async {
    await togglePrayer(prayer, value);
    final notifId = notificationIdOf(prayer);
    if (!value) {
      await NotificationHelper().cancelNotification(notifId);
      return true;
    }

    final success = await _schedulePrayerNotification(prayer, notifId);
    if (!success) await togglePrayer(prayer, false);
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

  void toggleNotificationExpansion() {
    _isNotificationExpanded = !_isNotificationExpanded;
    notifyListeners();
  }

  void toggleAdjustmentExpansion() {
    _isAdjustmentExpanded = !_isAdjustmentExpanded;
    notifyListeners();
  }

  /// Turns the reminder for prayers not marked yet on or off. Returns
  /// false, leaving it off, when there are no prayer times to use.
  Future<bool> toggleMissedReminder(bool value) async {
    _isMissedReminderEnabled = value;
    await prefs.setBool(NotificationHelper.keyMissedReminder, value);

    if (!value) {
      await NotificationHelper().disableMissedReminders();
    } else {
      final PrayerModel? prayerModel = await PrayerProxy().getTodayPrayer();
      if (prayerModel == null) {
        _isMissedReminderEnabled = false;
        await prefs.setBool(NotificationHelper.keyMissedReminder, false);
        notifyListeners();
        return false;
      }
      await NotificationHelper().scheduleMissedReminders(prayerModel);
    }

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

    notifyListeners();
    return true;
  }

  Future<bool> toggleReminder(bool value) async {
    _isReminderEnabled = value;
    await prefs.setBool('isReminderEnabled', value);

    if (!value) {
      await NotificationHelper().disableReminderNotifications(true);
    } else {
      final PrayerModel? prayerModel = await PrayerProxy().getTodayPrayer();
      if (prayerModel == null) {
        _isReminderEnabled = false;
        await prefs.setBool('isReminderEnabled', false);
        notifyListeners();
        return false;
      }
      await NotificationHelper().scheduleReminderNotifications(prayerModel);
    }

    notifyListeners();
    return true;
  }
}
