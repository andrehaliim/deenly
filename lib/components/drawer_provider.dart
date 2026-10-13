import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool _isAdjustmentExpanded = false;
  bool get isAdjustmentExpanded => _isAdjustmentExpanded;

  bool _isReminderEnabled = false;
  bool get isReminderEnabled => _isReminderEnabled;

  DrawerProvider(this.prefs) {
    _loadSettings();
  }

  static int notificationIdOf(String prayer) => prayers.indexOf(prayer) + 1;

  static String _enabledKey(String prayer) => 'is${prayer}Enabled';

  // Isha uses the legacy 'ishAdjustment' key already saved on devices.
  static String _adjustmentKey(String prayer) =>
      prayer == 'Isha' ? 'ishAdjustment' : '${prayer.toLowerCase()}Adjustment';

  bool isPrayerEnabled(String prayer) => _enabled[prayer] ?? false;

  int adjustmentOf(String prayer) => _adjustments[prayer] ?? 0;

  void _loadSettings() {
    for (final prayer in prayers) {
      _enabled[prayer] = prefs.getBool(_enabledKey(prayer)) ?? false;
      _adjustments[prayer] = prefs.getInt(_adjustmentKey(prayer)) ?? 0;
    }

    _isReminderEnabled = prefs.getBool('isReminderEnabled') ?? false;
  }

  Future<void> togglePrayer(String prayer, bool value) async {
    _enabled[prayer] = value;
    await prefs.setBool(_enabledKey(prayer), value);
    WidgetHelper().updateWidgetNotification(prayer.toLowerCase(), value);
    notifyListeners();
  }

  Future<void> setAdjustment(String prayer, int value) async {
    _adjustments[prayer] = value;
    await prefs.setInt(_adjustmentKey(prayer), value);
    notifyListeners();
  }

  void toggleAdjustmentExpansion() {
    _isAdjustmentExpanded = !_isAdjustmentExpanded;
    notifyListeners();
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
