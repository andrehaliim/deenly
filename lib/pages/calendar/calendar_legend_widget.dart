import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/calendar/calendar_marker_color.dart';
import 'package:flutter/material.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 6,
      children: [
        _LegendItem(
          color: CalendarMarkerColor.holiday(theme),
          label: l10n?.calendarLegendHoliday ?? '',
        ),
        _LegendItem(
          color: CalendarMarkerColor.sunnahFast(theme),
          label: l10n?.calendarLegendSunnahFast ?? '',
        ),
        _LegendItem(
          color: CalendarMarkerColor.forbiddenFast(theme),
          label: l10n?.calendarLegendForbiddenFast ?? '',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
