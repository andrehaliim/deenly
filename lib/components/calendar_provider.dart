import 'package:deenly/models/calendar_day_model.dart';
import 'package:deenly/models/event_occurrence_model.dart';
import 'package:deenly/models/hijri_date_model.dart';
import 'package:deenly/models/islamic_event_model.dart';
import 'package:deenly/proxys/calendar_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CalendarProvider extends ChangeNotifier {
  static const int maxAdjustment = 2;
  static const int _ramadan = 9;

  /// How far ahead to look for the next holiday: a little over a year,
  /// so every yearly event is always found.
  static const int _lookAheadDays = 400;

  final CalendarProxy _proxy = CalendarProxy();

  List<IslamicEventModel> _events = const [];
  int _adjustment = 0;
  Map<int, DateTime> _monthStarts = const {};
  bool _isHijriPrimary = false;
  bool _isLoaded = false;
  EventOccurrenceModel? _nextEvent;

  /// The month shown: a Gregorian month (day 1) or, when [isHijriPrimary],
  /// a Hijri month (day 1). Only the one matching the mode is used.
  DateTime _gregorianMonth = _monthOf(DateTime.now());
  HijriDateModel _hijriMonth = _hijriMonthOf(
    HijriDateModel.fromGregorian(DateTime.now()),
  );

  int get adjustment => _adjustment;

  /// Whether some months follow an official start date, which the user's
  /// [adjustment] does not shift.
  bool get hasOfficialMonthStarts => _monthStarts.isNotEmpty;
  bool get isHijriPrimary => _isHijriPrimary;
  bool get isLoaded => _isLoaded;
  EventOccurrenceModel? get nextEvent => _nextEvent;
  DateTime get gregorianMonth => _gregorianMonth;
  HijriDateModel get hijriMonth => _hijriMonth;

  Future<void> load() async {
    if (_isLoaded) {
      showToday();
      return;
    }

    try {
      _adjustment = await _proxy.getAdjustment();
      _isHijriPrimary = await _proxy.getHijriPrimary();
    } catch (e) {
      debugPrint('Reading calendar preferences failed: $e');
    }

    try {
      _events = await _proxy.getEvents();
    } catch (e, st) {
      debugPrint('Loading islamic events failed: $e\n$st');
    }

    _isLoaded = true;
    _nextEvent = _findNextEvent();
    showToday();
  }

  /// Called by the provider tree with the official month starts from the
  /// app config, keyed by month index (`year * 12 + month - 1`).
  void updateMonthStarts(Map<int, DateTime> starts) {
    if (mapEquals(starts, _monthStarts)) return;
    _monthStarts = starts;
    if (_isLoaded) _nextEvent = _findNextEvent();
    Future.microtask(notifyListeners);
  }

  /// Official month starts can move a date into the month before or after
  /// the calculated one, so those neighbours are checked too.
  HijriDateModel hijriOf(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final calculated = HijriDateModel.fromGregorian(
      day,
      adjustment: _adjustment,
    );
    final calculatedIndex = _monthIndex(calculated);
    for (
      var index = calculatedIndex - 1;
      index <= calculatedIndex + 1;
      index++
    ) {
      final start = _startOf(index);
      if (day.isBefore(start) || !day.isBefore(_startOf(index + 1))) continue;
      return HijriDateModel(
        index ~/ 12,
        index % 12 + 1,
        _daysBetween(start, day) + 1,
      );
    }
    return calculated;
  }

  /// First Gregorian day of the Hijri month at [index]: the official date
  /// when there is one, else the calculated date with the user's
  /// adjustment.
  DateTime _startOf(int index) {
    return _monthStarts[index] ??
        HijriDateModel(
          index ~/ 12,
          index % 12 + 1,
          1,
        ).toGregorian(adjustment: _adjustment);
  }

  CalendarDayModel dayOf(DateTime date) {
    final hijri = hijriOf(date);
    final events = _events.where((event) => event.occursOn(hijri)).toList();
    final isRamadan = hijri.month == _ramadan;
    final isForbidden = events.any(
      (event) => event.fasting == FastingType.forbidden,
    );

    /// Sunnah fasts don't apply on days fasting is forbidden or already
    /// obligatory, e.g. Ayyamul Bidh on 13 Dzulhijjah (a Tasyrik day).
    if (isForbidden || isRamadan) {
      events.removeWhere((event) => event.type == IslamicEventType.fasting);
    }
    final isMondayThursday =
        !isForbidden &&
        !isRamadan &&
        (date.weekday == DateTime.monday || date.weekday == DateTime.thursday);

    final FastingType? fasting;
    if (isForbidden) {
      fasting = FastingType.forbidden;
    } else if (isMondayThursday ||
        events.any((event) => event.fasting == FastingType.sunnah)) {
      fasting = FastingType.sunnah;
    } else {
      fasting = null;
    }

    return CalendarDayModel(
      date: DateTime(date.year, date.month, date.day),
      hijri: hijri,
      events: events,
      fasting: fasting,
      isMondayThursdayFast: isMondayThursday,
    );
  }

  List<CalendarDayModel> get monthDays {
    final DateTime start;
    final int length;
    if (_isHijriPrimary) {
      final index = _monthIndex(_hijriMonth);
      start = _startOf(index);
      length = _daysBetween(start, _startOf(index + 1));
    } else {
      start = _gregorianMonth;
      length = DateUtils.getDaysInMonth(start.year, start.month);
    }
    return [
      for (var i = 0; i < length; i++)
        dayOf(DateTime(start.year, start.month, start.day + i)),
    ];
  }

  /// Events that start in the month shown, in date order.
  List<EventOccurrenceModel> get monthEvents {
    return [
      for (final day in monthDays)
        for (final event in day.events)
          if (event.startsOn(day.hijri))
            EventOccurrenceModel(
              event: event,
              date: day.date,
              hijri: day.hijri,
            ),
    ];
  }

  bool get isShowingToday {
    final today = DateTime.now();
    if (_isHijriPrimary) return _hijriMonthOf(hijriOf(today)) == _hijriMonth;
    return _monthOf(today) == _gregorianMonth;
  }

  void showToday() {
    final today = DateTime.now();
    _gregorianMonth = _monthOf(today);
    _hijriMonth = _hijriMonthOf(hijriOf(today));
    notifyListeners();
  }

  void showNextMonth() => _moveMonth(1);

  void showPreviousMonth() => _moveMonth(-1);

  void _moveMonth(int step) {
    if (_isHijriPrimary) {
      final index = _hijriMonth.year * 12 + _hijriMonth.month - 1 + step;
      _hijriMonth = HijriDateModel(index ~/ 12, index % 12 + 1, 1);
    } else {
      _gregorianMonth = DateTime(
        _gregorianMonth.year,
        _gregorianMonth.month + step,
      );
    }
    notifyListeners();
  }

  /// Switches the main calendar, keeping today (or the middle of the
  /// month shown) in view.
  Future<void> setHijriPrimary(bool value) async {
    if (value == _isHijriPrimary) return;
    final days = monthDays;
    final today = DateTime.now();
    final focus = days.firstWhere(
      (day) => day.isSameDay(today),
      orElse: () => days[days.length ~/ 2],
    );

    _isHijriPrimary = value;
    _gregorianMonth = _monthOf(focus.date);
    _hijriMonth = _hijriMonthOf(focus.hijri);
    notifyListeners();
    await _proxy.saveHijriPrimary(value);
  }

  Future<void> setAdjustment(int days) async {
    final value = days.clamp(-maxAdjustment, maxAdjustment);
    if (value == _adjustment) return;
    _adjustment = value;
    _nextEvent = _findNextEvent();
    notifyListeners();
    await _proxy.saveAdjustment(value);
  }

  EventOccurrenceModel? _findNextEvent() {
    final today = DateTime.now();
    for (var i = 0; i < _lookAheadDays; i++) {
      final date = DateTime(today.year, today.month, today.day + i);
      final hijri = hijriOf(date);
      for (final event in _events) {
        if (event.isHoliday && event.startsOn(hijri)) {
          return EventOccurrenceModel(event: event, date: date, hijri: hijri);
        }
      }
    }
    return null;
  }

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  static int _monthIndex(HijriDateModel date) =>
      date.year * 12 + date.month - 1;

  static int _daysBetween(DateTime from, DateTime to) {
    final start = DateTime.utc(from.year, from.month, from.day);
    return DateTime.utc(to.year, to.month, to.day).difference(start).inDays;
  }

  static HijriDateModel _hijriMonthOf(HijriDateModel date) =>
      HijriDateModel(date.year, date.month, 1);
}
