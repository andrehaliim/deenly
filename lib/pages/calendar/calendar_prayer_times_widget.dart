import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';

/// Prayer times of [date] from the stored yearly schedule, or a note when
/// that date has not been downloaded.
class CalendarPrayerTimes extends StatefulWidget {
  final DateTime date;

  const CalendarPrayerTimes({super.key, required this.date});

  @override
  State<CalendarPrayerTimes> createState() => _CalendarPrayerTimesState();
}

class _CalendarPrayerTimesState extends State<CalendarPrayerTimes> {
  late final Future<PrayerModel?> _prayer = _load();

  Future<PrayerModel?> _load() async {
    try {
      return await PrayerProxy().getPrayerForDate(widget.date);
    } catch (e) {
      debugPrint('Loading prayer times for calendar failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<PrayerModel?>(
      future: _prayer,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final prayer = snapshot.data;
        if (prayer == null) {
          return Text(
            l10n?.calendarPrayerUnavailable ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          );
        }

        final times = [
          (l10n?.fajr ?? '', prayer.fajr),
          (l10n?.sunrise ?? '', prayer.sunrise),
          (l10n?.dhuhr ?? '', prayer.dhuhr),
          (l10n?.asr ?? '', prayer.asr),
          (l10n?.maghrib ?? '', prayer.maghrib),
          (l10n?.isha ?? '', prayer.isha),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
            final width = (constraints.maxWidth - spacing * 2) / 3;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final (label, time) in times)
                  SizedBox(
                    width: width,
                    child: _PrayerTimeTile(label: label, time: time),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PrayerTimeTile extends StatelessWidget {
  final String label;
  final String time;

  const _PrayerTimeTile({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time.isEmpty ? '-' : time,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
