import 'package:deenly/components/hijri_format.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/calendar_day_model.dart';
import 'package:deenly/models/islamic_event_model.dart';
import 'package:deenly/pages/calendar/calendar_marker_color.dart';
import 'package:deenly/pages/calendar/calendar_practice_tile_widget.dart';
import 'package:deenly/pages/calendar/calendar_prayer_times_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bottom sheet for a tapped day: both dates, its events and practices,
/// and the prayer times.
class CalendarDayDetailSheet extends StatelessWidget {
  final CalendarDayModel day;

  const CalendarDayDetailSheet({super.key, required this.day});

  static const int _ramadan = 9;

  /// Ramadan days whose evening begins an odd night of the last ten
  /// (21st–29th): a Hijri night begins at Maghrib the day before its date.
  static const Set<int> _daysBeforeOddNights = {20, 22, 24, 26, 28};

  static Future<void> show(BuildContext context, CalendarDayModel day) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => CalendarDayDetailSheet(day: day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isForbidden = day.fasting == FastingType.forbidden;
    final isRamadan = day.hijri.month == _ramadan;
    final isBeforeOddNight =
        isRamadan && _daysBeforeOddNights.contains(day.hijri.day);

    final practices = [
      for (final event in day.events)
        CalendarPracticeTile(
          color: CalendarMarkerColor.ofEvent(theme, event),
          title: event.name(languageCode),
          description: event.description(languageCode),
        ),
      if (isBeforeOddNight)
        CalendarPracticeTile(
          color: CalendarMarkerColor.holiday(theme),
          title: l10n?.calendarOddNight(day.hijri.day + 1) ?? '',
          description: l10n?.calendarOddNightDesc ?? '',
        ),
      if (isRamadan)
        CalendarPracticeTile(
          color: CalendarMarkerColor.sunnahFast(theme),
          title: l10n?.calendarRamadanFast ?? '',
          description: l10n?.calendarRamadanFastDesc ?? '',
        ),
      if (day.isMondayThursdayFast)
        CalendarPracticeTile(
          color: CalendarMarkerColor.sunnahFast(theme),
          title: l10n?.calendarMondayThursdayFast ?? '',
          description: l10n?.calendarMondayThursdayFastDesc ?? '',
        ),
    ];

    final sectionStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              HijriFormat.full(l10n, day.hijri),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat.yMMMMEEEEd(languageCode).format(day.date),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (isForbidden) ...[
              const SizedBox(height: 10),
              _ForbiddenBadge(label: l10n?.calendarLegendForbiddenFast ?? ''),
            ],
            const SizedBox(height: 20),
            if (practices.isEmpty)
              Text(
                l10n?.calendarNoPractice ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final practice in practices) ...[
                practice,
                const SizedBox(height: 8),
              ],
            const SizedBox(height: 16),
            Text(l10n?.calendarPrayerTimes ?? '', style: sectionStyle),
            const SizedBox(height: 10),
            CalendarPrayerTimes(date: day.date),
          ],
        ),
      ),
    );
  }
}

class _ForbiddenBadge extends StatelessWidget {
  final String label;

  const _ForbiddenBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block_rounded,
            size: 14,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
