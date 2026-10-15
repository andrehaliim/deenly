import 'dart:convert';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerProxy {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  static const List<String> _prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  // Isha uses the legacy 'ishAdjustment' key already saved on devices.
  static String adjustmentKey(String prayer) =>
      prayer == 'Isha' ? 'ishAdjustment' : '${prayer.toLowerCase()}Adjustment';

  Future<PrayerModel?> getTodayPrayer() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final formattedDate =
        "${twoDigits(now.day)}-${twoDigits(now.month)}-${now.year}";

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT * FROM prayer WHERE date = ?",
      [formattedDate],
    );
    if (maps.isNotEmpty) {
      debugPrint('Prayer loaded from local database');
      return PrayerModel.fromJsonDB(maps.first);
    } else {
      return null;
    }
  }

  Future<void> fetchYearlyPrayer(double lat, double lon) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final deviceTimezone = tz.local.name;

    final uri = Uri.parse('$_baseUrl/calendar/${now.year}').replace(
      queryParameters: {
        'latitude': '$lat',
        'longitude': '$lon',
        'method': '20',
        'timezonestring': deviceTimezone,
        'annual': 'true',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);

      final monthsMap = decodedResponse['data'] as Map<String, dynamic>;

      final prayers = monthsMap.values
          .expand((monthList) => (monthList as List))
          .map((e) => PrayerModel.fromJsonApi(e))
          .toList();

      // Re-apply the user's saved adjustments, since the API returns
      // unadjusted times and the table is rebuilt from scratch.
      final adjustments = await _savedAdjustments();

      final batch = db.batch();
      batch.delete('prayer');

      for (var prayer in prayers) {
        final row = prayer.toJson();
        for (final entry in adjustments.entries) {
          row[entry.key] = _adjustTime(row[entry.key] as String, entry.value);
        }
        batch.insert(
          'prayer',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      debugPrint('Prayer loaded from API (yearly: ${now.year})');
      await batch.commit(noResult: true);
    } else {
      throw Exception('Failed to load yearly prayer time');
    }
  }

  Map<String, String> getNextPrayer(Map<String, dynamic> timings) {
    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    String nextPrayer = 'Fajr';
    String nextTime = timings['Fajr'];

    for (var prayer in prayers) {
      final prayerTimeStr = timings[prayer] as String;
      final parts = prayerTimeStr.split(':');
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (prayerTime.isAfter(now)) {
        nextPrayer = prayer;
        nextTime = prayerTimeStr;
        break;
      }
    }
    return {'nextPrayer': nextPrayer, 'nextTime': nextTime};
  }

  Future<Map<String, int>> _savedAdjustments() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final prayer in _prayerNames)
        prayer: prefs.getInt(adjustmentKey(prayer)) ?? 0,
    };
  }

  /// Shifts the stored prayer times so they match [adjustments] (minutes
  /// per prayer name, e.g. 'Fajr'), then persists them as the new baseline.
  Future<void> saveAdjustments(Map<String, int> adjustments) async {
    final saved = await _savedAdjustments();

    // Prayer table columns are lowercase ('fajr', 'dhuhr', ...).
    final deltas = {
      for (final entry in adjustments.entries)
        entry.key.toLowerCase(): entry.value - (saved[entry.key] ?? 0),
    };
    debugPrint('Prayer adjustment deltas: $deltas');
    await updatePrayerTimesInDB(deltas);

    final prefs = await SharedPreferences.getInstance();
    for (final entry in adjustments.entries) {
      await prefs.setInt(adjustmentKey(entry.key), entry.value);
    }
  }

  Future<void> updatePrayerTimesInDB(Map<String, int> adjustments) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('prayer');
    final batch = db.batch();

    for (final map in maps) {
      final updated = {
        for (final entry in adjustments.entries)
          entry.key: _adjustTime(map[entry.key] as String, entry.value),
      };

      batch.update('prayer', updated, where: 'id = ?', whereArgs: [map['id']]);
    }

    await batch.commit(noResult: true);
  }

  String _adjustTime(String time, int minutes) {
    if (time.isEmpty) return time;
    final parts = time.split(':');
    if (parts.length != 2) return time;
    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);
    DateTime dt = DateTime(2000, 1, 1, h, m).add(Duration(minutes: minutes));
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String getPrayerLabel(BuildContext context, String prayer) {
    final l10n = AppLocalizations.of(context)!;
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return l10n.fajr;
      case 'dhuhr':
        return l10n.dhuhr;
      case 'asr':
        return l10n.asr;
      case 'maghrib':
        return l10n.maghrib;
      case 'isha':
        return l10n.isha;
      default:
        return prayer;
    }
  }
}
