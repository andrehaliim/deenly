import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  bool _isFajrEnabled = false;
  bool _isDhuhrEnabled = false;
  bool _isAsrEnabled = false;
  bool _isMaghribEnabled = false;
  bool _isIshaEnabled = false;

  int _fajradjustment = 0;
  int _dhuhradjustment = 0;
  int _asradjustment = 0;
  int _maghribadjustment = 0;
  int _ishadjustment = 0;

  bool get isFajrEnabled => _isFajrEnabled;
  bool get isDhuhrEnabled => _isDhuhrEnabled;
  bool get isAsrEnabled => _isAsrEnabled;
  bool get isMaghribEnabled => _isMaghribEnabled;
  bool get isIshaEnabled => _isIshaEnabled;

  int get fajradjustment => _fajradjustment;
  int get dhuhradjustment => _dhuhradjustment;
  int get asradjustment => _asradjustment;
  int get maghribadjustment => _maghribadjustment;
  int get ishadjustment => _ishadjustment;

  DrawerProvider(this.prefs) {
    _loadSettings();
  }

  void _loadSettings() {
    _isFajrEnabled = prefs.getBool('isFajrEnabled') ?? false;
    _isDhuhrEnabled = prefs.getBool('isDhuhrEnabled') ?? false;
    _isAsrEnabled = prefs.getBool('isAsrEnabled') ?? false;
    _isMaghribEnabled = prefs.getBool('isMaghribEnabled') ?? false;
    _isIshaEnabled = prefs.getBool('isIshaEnabled') ?? false;

    _fajradjustment = prefs.getInt('fajrAdjustment') ?? 0;
    _dhuhradjustment = prefs.getInt('dhuhrAdjustment') ?? 0;
    _asradjustment = prefs.getInt('asrAdjustment') ?? 0;
    _maghribadjustment = prefs.getInt('maghribAdjustment') ?? 0;
    _ishadjustment = prefs.getInt('ishAdjustment') ?? 0;
  }

  Future<void> toggleFajr(bool value) async {
    _isFajrEnabled = value;
    await prefs.setBool('isFajrEnabled', value);
    notifyListeners();
  }

  Future<void> toggleDhuhr(bool value) async {
    _isDhuhrEnabled = value;
    await prefs.setBool('isDhuhrEnabled', value);
    notifyListeners();
  }

  Future<void> toggleAsr(bool value) async {
    _isAsrEnabled = value;
    await prefs.setBool('isAsrEnabled', value);
    notifyListeners();
  }

  Future<void> toggleMaghrib(bool value) async {
    _isMaghribEnabled = value;
    await prefs.setBool('isMaghribEnabled', value);
    notifyListeners();
  }

  Future<void> toggleIsha(bool value) async {
    _isIshaEnabled = value;
    await prefs.setBool('isIshaEnabled', value);
    notifyListeners();
  }

  Future<void> setFajrAdjustment(int value) async {
    _fajradjustment = value;
    await prefs.setInt('fajrAdjustment', value);
    notifyListeners();
  }

  Future<void> setDhuhrAdjustment(int value) async {
    _dhuhradjustment = value;
    await prefs.setInt('dhuhrAdjustment', value);
    notifyListeners();
  }

  Future<void> setAsrAdjustment(int value) async {
    _asradjustment = value;
    await prefs.setInt('asrAdjustment', value);
    notifyListeners();
  }

  Future<void> setMaghribAdjustment(int value) async {
    _maghribadjustment = value;
    await prefs.setInt('maghribAdjustment', value);
    notifyListeners();
  }

  Future<void> setIshaAdjustment(int value) async {
    _ishadjustment = value;
    await prefs.setInt('ishAdjustment', value);
    notifyListeners();
  }
}
