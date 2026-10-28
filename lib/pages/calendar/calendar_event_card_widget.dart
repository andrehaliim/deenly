import 'package:deenly/components/hijri_format.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/event_occurrence_model.dart';
import 'package:deenly/pages/calendar/calendar_marker_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarEventCard extends StatelessWidget {
  final EventOccurrenceModel occurrence;
  final VoidCallback onTap;

  const CalendarEventCard({
    super.key,
    required this.occurrence,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final event = occurrence.event;
    final accent = CalendarMarkerColor.ofEvent(theme, event);
    final weekday = DateFormat.EEEE(languageCode).format(occurrence.date);
    final borderRadius = BorderRadius.circular(20);

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${occurrence.date.day}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accent,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      DateFormat.MMM(languageCode).format(occurrence.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name(languageCode),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${HijriFormat.full(l10n, occurrence.hijri)} · '
                      '$weekday',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
