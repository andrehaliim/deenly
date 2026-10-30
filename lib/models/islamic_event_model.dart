import 'package:deenly/models/hijri_date_model.dart';

/// [info] is shown on its day and in the month's events only: no
/// countdown, reminder, grid marker or fasting status.
enum IslamicEventType { holiday, fasting, info }

enum FastingType { sunnah, forbidden }

class IslamicEventModel {
  final String id;

  /// Null for events that repeat every Hijri month (e.g. Ayyamul Bidh).
  final int? month;
  final int day;
  final int duration;
  final IslamicEventType type;
  final FastingType? fasting;
  final String nameEnglish;
  final String nameIndonesian;
  final String descriptionEnglish;
  final String descriptionIndonesian;

  const IslamicEventModel({
    required this.id,
    required this.month,
    required this.day,
    required this.duration,
    required this.type,
    required this.fasting,
    required this.nameEnglish,
    required this.nameIndonesian,
    required this.descriptionEnglish,
    required this.descriptionIndonesian,
  });

  factory IslamicEventModel.fromJson(Map<String, dynamic> json) {
    return IslamicEventModel(
      id: json['id'],
      month: json['month'],
      day: json['day'],
      duration: json['duration'] ?? 1,
      type: switch (json['type']) {
        'fasting' => IslamicEventType.fasting,
        'info' => IslamicEventType.info,
        _ => IslamicEventType.holiday,
      },
      fasting: switch (json['fasting']) {
        'sunnah' => FastingType.sunnah,
        'forbidden' => FastingType.forbidden,
        _ => null,
      },
      nameEnglish: json['name_en'],
      nameIndonesian: json['name_id'],
      descriptionEnglish: json['description_en'],
      descriptionIndonesian: json['description_id'],
    );
  }

  bool get isHoliday => type == IslamicEventType.holiday;

  String name(String languageCode) =>
      languageCode == 'id' ? nameIndonesian : nameEnglish;

  String description(String languageCode) =>
      languageCode == 'id' ? descriptionIndonesian : descriptionEnglish;

  bool occursOn(HijriDateModel date) {
    final month = this.month;
    if (month != null && month != date.month) return false;
    return date.day >= day && date.day < day + duration;
  }

  /// True on the first day of the event, where it is listed and counted
  /// down to.
  bool startsOn(HijriDateModel date) {
    final month = this.month;
    return (month == null || month == date.month) && date.day == day;
  }
}
