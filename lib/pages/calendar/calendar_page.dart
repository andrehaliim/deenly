import 'package:deenly/components/calendar_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/calendar/calendar_adjustment_sheet.dart';
import 'package:deenly/pages/calendar/calendar_day_detail_sheet.dart';
import 'package:deenly/pages/calendar/calendar_event_card_widget.dart';
import 'package:deenly/pages/calendar/calendar_grid_widget.dart';
import 'package:deenly/pages/calendar/calendar_hero_card_widget.dart';
import 'package:deenly/pages/calendar/calendar_legend_widget.dart';
import 'package:deenly/pages/calendar/calendar_month_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Hijri + Gregorian month calendar with Islamic holidays and fasting
/// days. Built to be pushed from the home menu, which supplies the app
/// bar.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<CalendarProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CalendarProvider>();

    if (!provider.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final days = provider.monthDays;
    final events = provider.monthEvents;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const CalendarHeroCard(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n?.calendarGregorian ?? ''),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n?.calendarHijri ?? ''),
                  ),
                ],
                selected: {provider.isHijriPrimary},
                onSelectionChanged: (selection) =>
                    provider.setHijriPrimary(selection.first),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: l10n?.calendarAdjustment,
              onPressed: () => CalendarAdjustmentSheet.show(context),
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              CalendarMonthHeader(days: days),
              if (!provider.isShowingToday)
                TextButton.icon(
                  onPressed: provider.showToday,
                  icon: const Icon(Icons.today_rounded, size: 18),
                  label: Text(l10n?.calendarToday ?? ''),
                ),
              const SizedBox(height: 4),
              CalendarGrid(
                days: days,
                isHijriPrimary: provider.isHijriPrimary,
                onDayTap: (day) => CalendarDayDetailSheet.show(context, day),
              ),
              const SizedBox(height: 12),
              const CalendarLegend(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n?.calendarMonthEvents ?? '',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Text(
            l10n?.calendarNoEvents ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (final occurrence in events) ...[
            CalendarEventCard(
              occurrence: occurrence,
              onTap: () => CalendarDayDetailSheet.show(
                context,
                provider.dayOf(occurrence.date),
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
