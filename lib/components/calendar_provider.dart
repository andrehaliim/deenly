import 'package:deenly/components/hijri_calendar_helper.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/models/calendar_day_model.dart';
import 'package:deenly/models/event_occurrence_model.dart';
import 'package:deenly/models/hijri_date_model.dart';
import 'package:deenly/proxys/calendar_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CalendarProvider extends ChangeNotifier {
  static const int maxAdjustment = 2;

  /// How far ahead to look for the next holiday: a little over a year,
  /// so every yearly event is always found.
  static const int _lookAheadDays = 400;

  final CalendarProxy _proxy = CalendarProxy();

  HijriCalendarHelper _calendar = const HijriCalendarHelper();
  bool _isHijriPrimary = false;
  bool _isLoaded = false;
  Future<void>? _loading;
  EventOccurrenceModel? _nextEvent;

  /// The day [_nextEvent] was found for; null when it must be found again.
  DateTime? _nextEventDay;

  /// The month shown: a Gregorian month (day 1) or, when [isHijriPrimary],
  /// a Hijri month (day 1). Only the one matching the mode is used.
  DateTime _gregorianMonth = _monthOf(DateTime.now());
  HijriDateModel _hijriMonth = _hijriMonthOf(
    HijriDateModel.fromGregorian(DateTime.now()),
  );

  int get adjustment => _calendar.adjustment;

  /// Whether some months follow an official start date, which the user's
  /// [adjustment] does not shift.
  bool get hasOfficialMonthStarts => _calendar.monthStarts.isNotEmpty;
  bool get isHijriPrimary => _isHijriPrimary;
  bool get isLoaded => _isLoaded;

  /// Found again once the day changes, so the countdown moves on after
  /// midnight even while the app stays open.
  EventOccurrenceModel? get nextEvent {
    final today = DateUtils.dateOnly(DateTime.now());
    if (_nextEventDay != today) {
      _nextEvent = _findNextEvent(today);
      _nextEventDay = today;
    }
    return _nextEvent;
  }

  DateTime get gregorianMonth => _gregorianMonth;
  HijriDateModel get hijriMonth => _hijriMonth;

  /// Safe to call more than once (home and the calendar page both do);
  /// the data is read once and each call shows today's month.
  Future<void> load() async {
    await (_loading ??= _loadData());
    showToday();
  }

  Future<void> _loadData() async {
    try {
      _calendar = _calendar.copyWith(adjustment: await _proxy.getAdjustment());
      _isHijriPrimary = await _proxy.getHijriPrimary();
    } catch (e) {
      debugPrint('Reading calendar preferences failed: $e');
    }

    try {
      _calendar = _calendar.copyWith(events: await _proxy.getEvents());
    } catch (e, st) {
      debugPrint('Loading islamic events failed: $e\n$st');
    }

    _isLoaded = true;
    _nextEventDay = null;
  }

  /// Called by the provider tree with the official month starts from the
  /// app config, keyed by month index (`year * 12 + month - 1`).
  /// New isbat dates can move today into another Hijri month and the
  /// holidays to other days, so the month shown and the reminders follow.
  void updateMonthStarts(Map<int, DateTime> starts) {
    if (mapEquals(starts, _calendar.monthStarts)) return;
    final wasShowingToday = isShowingToday;
    _calendar = _calendar.copyWith(monthStarts: starts);
    _nextEventDay = null;
    if (wasShowingToday) {
      _hijriMonth = _hijriMonthOf(hijriOf(DateTime.now()));
    }
    Future.microtask(notifyListeners);
    NotificationHelper().scheduleCalendarReminders().catchError(
      (Object e) => debugPrint('Rescheduling calendar reminders failed: $e'),
    );
  }

  HijriDateModel hijriOf(DateTime date) => _calendar.hijriOf(date);

  CalendarDayModel dayOf(DateTime date) => _calendar.dayOf(date);

  List<CalendarDayModel> get monthDays {
    final DateTime start;
    final int length;
    if (_isHijriPrimary) {
      final index = HijriCalendarHelper.monthIndex(_hijriMonth);
      start = _calendar.startOf(index);
      length = HijriCalendarHelper.daysBetween(
        start,
        _calendar.startOf(index + 1),
      );
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

  /// Also reschedules the calendar reminders, which are dated by the
  /// adjusted calendar.
  Future<void> setAdjustment(int days) async {
    final value = days.clamp(-maxAdjustment, maxAdjustment);
    if (value == adjustment) return;
    _calendar = _calendar.copyWith(adjustment: value);
    _nextEventDay = null;
    notifyListeners();
    await _proxy.saveAdjustment(value);
    await NotificationHelper().scheduleCalendarReminders();
  }

  EventOccurrenceModel? _findNextEvent(DateTime today) {
    for (var i = 0; i < _lookAheadDays; i++) {
      final date = DateTime(today.year, today.month, today.day + i);
      final hijri = hijriOf(date);
      for (final event in _calendar.events) {
        if (event.isHoliday && event.startsOn(hijri)) {
          return EventOccurrenceModel(event: event, date: date, hijri: hijri);
        }
      }
    }
    return null;
  }

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  static HijriDateModel _hijriMonthOf(HijriDateModel date) =>
      HijriDateModel(date.year, date.month, 1);
}
