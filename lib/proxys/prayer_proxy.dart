import 'dart:convert';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class PrayerProxy {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

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

  Future<void> fetchMonthlyPrayer(double lat, double lon) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/calendar/${now.year}/${now.month}?latitude=$lat&longitude=$lon&method=20&timezonestring=Asia%2FJakarta',
      ),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);

      final prayers = (decodedResponse['data'] as List)
          .map((e) => PrayerModel.fromJsonApi(e))
          .toList();

      final batch = db.batch();

      for (var prayer in prayers) {
        batch.insert(
          'prayer',
          prayer.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      debugPrint('Prayer loaded from API');
      await batch.commit(noResult: true);
    } else {
      throw Exception('Failed to load monthly prayer time');
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

  Future<void> clearPrayer() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('prayer');
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
}
