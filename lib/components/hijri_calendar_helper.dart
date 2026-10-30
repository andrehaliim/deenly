import 'package:deenly/models/calendar_day_model.dart';
import 'package:deenly/models/hijri_date_model.dart';
import 'package:deenly/models/islamic_event_model.dart';
import 'package:deenly/proxys/app_config_proxy.dart';
import 'package:deenly/proxys/calendar_proxy.dart';
import 'package:flutter/foundation.dart';

/// Resolves Hijri dates and the events of a day from the user's
/// adjustment and the official month starts. Has no Flutter state, so the
/// background task can use it as well as [CalendarProvider].
class HijriCalendarHelper {
  static const int _ramadan = 9;

  final List<IslamicEventModel> events;
  final int adjustment;

  /// Official month starts, keyed by month index
  /// (`year * 12 + month - 1`).
  final Map<int, DateTime> monthStarts;

  const HijriCalendarHelper({
    this.events = const [],
    this.adjustment = 0,
    this.monthStarts = const {},
  });

  /// The saved adjustment, the bundled events and the cached app config,
  /// for use without the provider tree.
  static Future<HijriCalendarHelper> loadSaved() async {
    final proxy = CalendarProxy();
    var events = const <IslamicEventModel>[];
    var adjustment = 0;
    var monthStarts = const <int, DateTime>{};
    try {
      adjustment = await proxy.getAdjustment();
      events = await proxy.getEvents();
      monthStarts = (await AppConfigProxy().getLocal()).hijriMonthStarts;
    } catch (e, st) {
      debugPrint('Loading saved calendar failed: $e\n$st');
    }
    return HijriCalendarHelper(
      events: events,
      adjustment: adjustment,
      monthStarts: monthStarts,
    );
  }

  HijriCalendarHelper copyWith({
    List<IslamicEventModel>? events,
    int? adjustment,
    Map<int, DateTime>? monthStarts,
  }) {
    return HijriCalendarHelper(
      events: events ?? this.events,
      adjustment: adjustment ?? this.adjustment,
      monthStarts: monthStarts ?? this.monthStarts,
    );
  }

  /// Whether the month of [date] starts on an official (isbat) date
  /// rather than a calculated one.
  bool isOfficialMonth(HijriDateModel date) =>
      monthStarts.containsKey(monthIndex(date));

  /// Official month starts can move a date into the month before or after
  /// the calculated one, so those neighbours are checked too.
  HijriDateModel hijriOf(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final calculated = HijriDateModel.fromGregorian(
      day,
      adjustment: adjustment,
    );
    final calculatedIndex = monthIndex(calculated);
    for (
      var index = calculatedIndex - 1;
      index <= calculatedIndex + 1;
      index++
    ) {
      final start = startOf(index);
      if (day.isBefore(start) || !day.isBefore(startOf(index + 1))) continue;
      return HijriDateModel(
        index ~/ 12,
        index % 12 + 1,
        daysBetween(start, day) + 1,
      );
    }
    return calculated;
  }

  /// First Gregorian day of the Hijri month at [index]: the official date
  /// when there is one, else the calculated date with the user's
  /// adjustment.
  DateTime startOf(int index) {
    return monthStarts[index] ??
        HijriDateModel(
          index ~/ 12,
          index % 12 + 1,
          1,
        ).toGregorian(adjustment: adjustment);
  }

  CalendarDayModel dayOf(DateTime date) {
    final hijri = hijriOf(date);
    final dayEvents = events.where((event) => event.occursOn(hijri)).toList();
    final isRamadan = hijri.month == _ramadan;
    final isForbidden = dayEvents.any(
      (event) => event.fasting == FastingType.forbidden,
    );

    /// Sunnah fasts don't apply on days fasting is forbidden or already
    /// obligatory, e.g. Ayyamul Bidh on 13 Dzulhijjah (a Tasyrik day).
    if (isForbidden || isRamadan) {
      dayEvents.removeWhere((event) => event.type == IslamicEventType.fasting);
    }
    final isMondayThursday =
        !isForbidden &&
        !isRamadan &&
        (date.weekday == DateTime.monday || date.weekday == DateTime.thursday);

    final FastingType? fasting;
    if (isForbidden) {
      fasting = FastingType.forbidden;
    } else if (isMondayThursday ||
        dayEvents.any((event) => event.fasting == FastingType.sunnah)) {
      fasting = FastingType.sunnah;
    } else {
      fasting = null;
    }

    return CalendarDayModel(
      date: DateTime(date.year, date.month, date.day),
      hijri: hijri,
      events: dayEvents,
      fasting: fasting,
      isMondayThursdayFast: isMondayThursday,
    );
  }

  static int monthIndex(HijriDateModel date) => date.year * 12 + date.month - 1;

  static int daysBetween(DateTime from, DateTime to) {
    final start = DateTime.utc(from.year, from.month, from.day);
    return DateTime.utc(to.year, to.month, to.day).difference(start).inDays;
  }
}
