import 'package:deenly/models/calendar_day_model.dart';
import 'package:deenly/pages/calendar/calendar_day_cell_widget.dart';
import 'package:flutter/material.dart';

/// Weekday header and one row per week, starting on the locale's first
/// day of the week.
class CalendarGrid extends StatelessWidget {
  final List<CalendarDayModel> days;
  final bool isHijriPrimary;
  final ValueChanged<CalendarDayModel> onDayTap;

  const CalendarGrid({
    super.key,
    required this.days,
    required this.isHijriPrimary,
    required this.onDayTap,
  });

  static const int _weekLength = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final firstWeekday = localizations.firstDayOfWeekIndex;

    /// [DateTime.weekday] is 1 (Mon)–7 (Sun); the localizations count
    /// from 0 (Sun).
    final leading =
        (days.first.date.weekday % _weekLength - firstWeekday) % _weekLength;
    final cells = <CalendarDayModel?>[...List.filled(leading, null), ...days];
    while (cells.length % _weekLength != 0) {
      cells.add(null);
    }
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < _weekLength; i++)
              Expanded(
                child: Center(
                  child: Text(
                    localizations.narrowWeekdays[(firstWeekday + i) %
                        _weekLength],
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: (firstWeekday + i) % _weekLength == 5
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var row = 0; row < cells.length; row += _weekLength)
          Row(
            children: [
              for (final day in cells.skip(row).take(_weekLength))
                Expanded(
                  child: day == null
                      ? const SizedBox(height: CalendarDayCell.height)
                      : CalendarDayCell(
                          day: day,
                          isToday: day.isSameDay(today),
                          isHijriPrimary: isHijriPrimary,
                          onTap: () => onDayTap(day),
                        ),
                ),
            ],
          ),
      ],
    );
  }
}
