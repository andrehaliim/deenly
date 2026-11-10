import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const localeKey = 'selected_locale';

  /// Fresh installs follow the device language: Indonesian on Indonesian
  /// devices, English on every other one. Read from the platform rather
  /// than a BuildContext, so the background isolate gets the same answer.
  static Locale get defaultLocale {
    final deviceCode = PlatformDispatcher.instance.locale.languageCode;
    return Locale(deviceCode == 'id' ? 'id' : 'en');
  }

  Locale? _locale = defaultLocale;
  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(localeKey);
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = defaultLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(localeKey);
    notifyListeners();
  }
}
