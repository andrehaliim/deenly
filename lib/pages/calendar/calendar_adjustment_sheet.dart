import 'package:deenly/components/calendar_provider.dart';
import 'package:deenly/components/hijri_format.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shifts the calculated Hijri date by up to two days either way, with a
/// preview of today's date.
class CalendarAdjustmentSheet extends StatelessWidget {
  const CalendarAdjustmentSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const CalendarAdjustmentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CalendarProvider>();
    final adjustment = provider.adjustment;
    const max = CalendarProvider.maxAdjustment;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.calendarAdjustment ?? '',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.calendarAdjustmentHint ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (provider.hasOfficialMonthStarts) ...[
            const SizedBox(height: 6),
            Text(
              l10n?.calendarAdjustmentOfficialNote ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (var days = -max; days <= max; days++)
                  ButtonSegment(
                    value: days,
                    label: Text(days > 0 ? '+$days' : '$days'),
                  ),
              ],
              selected: {adjustment},
              onSelectionChanged: (selection) =>
                  provider.setAdjustment(selection.first),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  l10n?.calendarToday ?? '',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  HijriFormat.full(l10n, provider.hijriOf(DateTime.now())),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  l10n?.calendarAdjustmentDays(adjustment) ?? '',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
