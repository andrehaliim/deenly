import 'package:deenly/models/prayer_model.dart';

/// The daily dzikir windows, each tied to its category id in dzikir.json.
enum DzikirPeriod {
  morning(categoryId: 1),
  evening(categoryId: 2);

  final int categoryId;

  const DzikirPeriod({required this.categoryId});

  /// Morning runs from Fajr to sunrise, evening from Asr to Maghrib.
  /// Returns null outside both windows or when a time cannot be parsed.
  static DzikirPeriod? at(PrayerModel prayer, DateTime now) {
    final minute = now.hour * 60 + now.minute;
    for (final period in values) {
      final start = _minuteOf(period.startTime(prayer));
      final end = _minuteOf(period.endTime(prayer));
      if (start == null || end == null) continue;
      if (minute >= start && minute < end) return period;
    }
    return null;
  }

  String startTime(PrayerModel prayer) => switch (this) {
    morning => prayer.fajr,
    evening => prayer.asr,
  };

  /// Older cached rows have no sunrise; Dhuhr then closes the morning.
  String endTime(PrayerModel prayer) => switch (this) {
    morning => prayer.sunrise.isNotEmpty ? prayer.sunrise : prayer.dhuhr,
    evening => prayer.maghrib,
  };

  static int? _minuteOf(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }
}
