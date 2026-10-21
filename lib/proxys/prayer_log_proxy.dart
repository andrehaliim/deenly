import 'package:deenly/components/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

/// Which prayers the user marked as done, per day.
class PrayerLogProxy {
  /// Prayers counted in the progress and the streak.
  static const List<String> trackedPrayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  /// How many days back a prayer can still be marked, besides today.
  static const int editableDays = 7;

  /// Sortable day key stored in the `date` column.
  static String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<Set<String>> getDonePrayers(DateTime date) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      DatabaseHelper.tablePrayerLog,
      columns: ['prayer'],
      where: 'date = ?',
      whereArgs: [dateKey(date)],
    );
    return {for (final row in rows) row['prayer'] as String};
  }

  /// Done prayers of every day from [from] to [to] inclusive, keyed by
  /// [dateKey]. Days without any are left out.
  Future<Map<String, Set<String>>> getDonePrayersBetween(
    DateTime from,
    DateTime to,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      DatabaseHelper.tablePrayerLog,
      columns: ['date', 'prayer'],
      where: 'date BETWEEN ? AND ?',
      whereArgs: [dateKey(from), dateKey(to)],
    );

    final result = <String, Set<String>>{};
    for (final row in rows) {
      result
          .putIfAbsent(row['date'] as String, () => {})
          .add(row['prayer'] as String);
    }
    return result;
  }

  /// Consecutive days, up to [today], on which all of [prayers] were done.
  /// An unfinished today does not break the streak yet.
  Future<int> getStreak(DateTime today, List<String> prayers) async {
    final db = await DatabaseHelper.instance.database;
    final placeholders = List.filled(prayers.length, '?').join(', ');
    final rows = await db.rawQuery(
      'SELECT date FROM ${DatabaseHelper.tablePrayerLog} '
      'WHERE prayer IN ($placeholders) AND date <= ? '
      'GROUP BY date HAVING COUNT(DISTINCT prayer) = ?',
      [...prayers, dateKey(today), prayers.length],
    );
    final completeDays = {for (final row in rows) row['date'] as String};

    var day = completeDays.contains(dateKey(today))
        ? today
        : DateUtils.addDaysToDate(today, -1);
    var streak = 0;
    while (completeDays.contains(dateKey(day))) {
      streak++;
      day = DateUtils.addDaysToDate(day, -1);
    }
    return streak;
  }

  Future<void> setDone(DateTime date, String prayer, bool isDone) async {
    final db = await DatabaseHelper.instance.database;
    if (isDone) {
      await db.insert(
        DatabaseHelper.tablePrayerLog,
        {
          'date': dateKey(date),
          'prayer': prayer,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete(
        DatabaseHelper.tablePrayerLog,
        where: 'date = ? AND prayer = ?',
        whereArgs: [dateKey(date), prayer],
      );
    }
  }
}
