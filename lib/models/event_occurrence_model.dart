import 'package:deenly/models/hijri_date_model.dart';
import 'package:deenly/models/islamic_event_model.dart';

/// An [IslamicEventModel] placed on the Gregorian date it starts.
class EventOccurrenceModel {
  final IslamicEventModel event;
  final DateTime date;
  final HijriDateModel hijri;

  const EventOccurrenceModel({
    required this.event,
    required this.date,
    required this.hijri,
  });
}
