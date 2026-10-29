/// A date in the tabular (arithmetic) Islamic calendar, which can differ
/// from the moon-sighting date by a day or two. Users correct that with
/// the adjustment applied in [HijriDateModel.fromGregorian].
class HijriDateModel {
  final int year;
  final int month;
  final int day;

  const HijriDateModel(this.year, this.month, this.day);

  /// Julian Day Number of 1 Muharram 1 AH (16 July 622, civil epoch).
  static const int _epoch = 1948440;

  /// Julian Day Number of 1 January 1970.
  static const int _unixEpoch = 2440588;

  factory HijriDateModel.fromGregorian(DateTime date, {int adjustment = 0}) {
    return HijriDateModel._fromJulianDay(_julianDayOf(date) + adjustment);
  }

  factory HijriDateModel._fromJulianDay(int julianDay) {
    final year = ((30 * (julianDay - _epoch)) + 10646) ~/ 10631;
    final elapsed = julianDay - (29 + _julianDayOfHijri(year, 1, 1));
    final month = (elapsed / 29.5).ceil() + 1;
    final safeMonth = month.clamp(1, 12);
    final day = julianDay - _julianDayOfHijri(year, safeMonth, 1) + 1;
    return HijriDateModel(year, safeMonth, day);
  }

  /// Gregorian date that this Hijri date falls on, undoing [adjustment].
  DateTime toGregorian({int adjustment = 0}) {
    final julianDay = _julianDayOfHijri(year, month, day) - adjustment;
    final utc = DateTime.utc(1970).add(Duration(days: julianDay - _unixEpoch));
    return DateTime(utc.year, utc.month, utc.day);
  }

  static int _julianDayOfHijri(int year, int month, int day) {
    return day +
        (29.5 * (month - 1)).ceil() +
        (year - 1) * 354 +
        (3 + 11 * year) ~/ 30 +
        _epoch -
        1;
  }

  static int _julianDayOf(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    return utc.difference(DateTime.utc(1970)).inDays + _unixEpoch;
  }

  @override
  bool operator ==(Object other) =>
      other is HijriDateModel &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);
}
