import 'dart:convert';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Future<PrayerModel?> getTodayPrayer() => getPrayerForDate(DateTime.now());

  Future<PrayerModel?> getPrayerForDate(DateTime date) async {
    final db = await DatabaseHelper.instance.database;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final formattedDate =
        "${twoDigits(date.day)}-${twoDigits(date.month)}-${date.year}";

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

  /// Re-applies the saved adjustments, since the API returns unadjusted
  /// times.
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

      await db.transaction((txn) async {
        final adjustments = await _readAdjustments(txn);

        final batch = txn.batch();
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

        await batch.commit(noResult: true);
      });
      debugPrint('Prayer loaded from API (yearly: ${now.year})');
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

  Future<Map<String, int>> savedAdjustments() async {
    final db = await DatabaseHelper.instance.database;
    return _readAdjustments(db);
  }

  static Future<Map<String, int>> _readAdjustments(DatabaseExecutor db) async {
    final rows = await db.query(DatabaseHelper.tablePrayerAdjustment);
    final stored = {
      for (final row in rows) row['prayer'] as String: row['minutes'] as int,
    };
    return {for (final prayer in _prayerNames) prayer: stored[prayer] ?? 0};
  }

  /// Shifts the times and saves the new baseline in one transaction, so a
  /// failure can never apply the same adjustment twice.
  Future<void> saveAdjustments(Map<String, int> adjustments) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      final saved = await _readAdjustments(txn);

      final deltas = {
        for (final entry in adjustments.entries)
          entry.key.toLowerCase(): entry.value - (saved[entry.key] ?? 0),
      };
      debugPrint('Prayer adjustment deltas: $deltas');
      await _shiftPrayerTimes(txn, deltas);

      final batch = txn.batch();
      for (final entry in adjustments.entries) {
        batch.insert(
          DatabaseHelper.tablePrayerAdjustment,
          {'prayer': entry.key, 'minutes': entry.value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> _shiftPrayerTimes(
    DatabaseExecutor db,
    Map<String, int> adjustments,
  ) async {
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
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String getPrayerLabel(BuildContext context, String prayer) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return prayer;
    return prayerLabelOf(l10n, prayer);
  }

  /// Localized name of [prayer] ('Fajr', 'Dhuhr', ...) without a
  /// [BuildContext], e.g. for notifications built in the background.
  static String prayerLabelOf(AppLocalizations l10n, String prayer) {
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
