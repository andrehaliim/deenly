import 'dart:convert';

import 'package:deenly/models/islamic_event_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class CalendarProxy {
  static const String _assetPath = 'assets/jsons/islamic_events.json';
  static const String _adjustmentKey = 'hijriAdjustment';
  static const String _hijriPrimaryKey = 'isCalendarHijriPrimary';

  Future<List<IslamicEventModel>> getEvents() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => IslamicEventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getAdjustment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_adjustmentKey) ?? 0;
  }

  Future<void> saveAdjustment(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_adjustmentKey, days);
  }

  Future<bool> getHijriPrimary() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hijriPrimaryKey) ?? false;
  }

  Future<void> saveHijriPrimary(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hijriPrimaryKey, value);
  }
}
