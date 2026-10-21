import 'package:flutter/material.dart';

/// Icon of [prayer] ('Imsak', 'Fajr', 'Sunrise', 'Dhuhr', ...), shared by
/// the home hero and the prayers schedule.
IconData prayerIconOf(String prayer) {
  switch (prayer) {
    case 'Imsak':
      return Icons.dark_mode_outlined;
    case 'Fajr':
      return Icons.wb_twilight_rounded;
    case 'Sunrise':
      return Icons.wb_sunny_outlined;
    case 'Dhuhr':
      return Icons.light_mode_outlined;
    case 'Asr':
      return Icons.filter_drama_outlined;
    case 'Maghrib':
      return Icons.nights_stay_outlined;
    default:
      return Icons.bedtime_outlined;
  }
}
