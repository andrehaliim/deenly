import 'package:deenly/components/app_colors.dart';
import 'package:deenly/components/calendar_provider.dart';
import 'package:deenly/components/hijri_format.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Hero card with today's Hijri date and a countdown to the next
/// Islamic holiday.
class CalendarHeroCard extends StatelessWidget {
  const CalendarHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final provider = context.watch<CalendarProvider>();
    final today = DateTime.now();
    final next = provider.nextEvent;
    final daysLeft = next == null
        ? 0
        : DateUtils.dateOnly(next.date)
              .difference(DateUtils.dateOnly(today))
              .inDays;
    final isOngoing = daysLeft < 0;
    final onHero = colorScheme.onPrimary;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: appColors?.heroGradient,
        boxShadow: [
          BoxShadow(
            color: appColors?.heroShadow ?? colorScheme.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            bottom: -20,
            child: FaIcon(
              FontAwesomeIcons.moon,
              size: 96,
              color: onHero.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMEEEEd(languageCode).format(today),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onHero.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    HijriFormat.full(l10n, provider.hijriOf(today)),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onHero,
                    ),
                  ),
                ),
                if (next != null) ...[
                  const SizedBox(height: 16),
                  Divider(height: 1, color: onHero.withValues(alpha: 0.2)),
                  const SizedBox(height: 14),
                  Text(
                    (isOngoing
                            ? l10n?.calendarOngoingEvent
                            : l10n?.calendarNextEvent) ??
                        '',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: onHero.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${next.event.name(languageCode)} '
                              '${next.hijri.year}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onHero,
                              ),
                            ),
                            Text(
                              DateFormat.yMMMMd(languageCode).format(next.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: onHero.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CountdownBadge(days: daysLeft),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  /// Days until the event; negative while it is going on, counting back
  /// from its first day.
  final int days;

  const _CountdownBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryFixed,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        switch (days) {
              0 => l10n?.calendarToday,
              < 0 => l10n?.calendarEventDay(1 - days),
              _ => l10n?.calendarDaysLeft(days),
            } ??
            '',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSecondaryFixed,
        ),
      ),
    );
  }
}
