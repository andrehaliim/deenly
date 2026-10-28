import 'package:deenly/models/hijri_date_model.dart';
import 'package:deenly/models/islamic_event_model.dart';

class CalendarDayModel {
  final DateTime date;
  final HijriDateModel hijri;
  final List<IslamicEventModel> events;
  final FastingType? fasting;

  /// Monday and Thursday fasts, which come from the weekday rather than
  /// an event, so they are flagged separately.
  final bool isMondayThursdayFast;

  const CalendarDayModel({
    required this.date,
    required this.hijri,
    required this.events,
    required this.fasting,
    required this.isMondayThursdayFast,
  });

  bool get hasHoliday => events.any((event) => event.isHoliday);

  bool isSameDay(DateTime other) =>
      date.year == other.year &&
      date.month == other.month &&
      date.day == other.day;
}
