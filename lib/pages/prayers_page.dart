import 'package:deenly/pages/home/home_prayer_progress.dart';
import 'package:flutter/material.dart';

/// Prayers tab. For now it only hosts the daily prayer progress that used
/// to live on the home page; the full schedule comes later.
class PrayersPage extends StatelessWidget {
  const PrayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: HomePrayerProgress(),
    );
  }
}
