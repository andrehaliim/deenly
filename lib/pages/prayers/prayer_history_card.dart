import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/prayer_log_proxy.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum _CellState { done, missed, upcoming }

/// Recap of the last [days] days: a grid of every tracked prayer per day,
/// the completion rate and the current streak. Tapping a day opens it in
/// the schedule above.
class PrayerHistoryCard extends StatelessWidget {
  /// Oldest first, ending today.
  final List<DateTime> days;
  final List<String> prayers;

  /// Done prayers per day, keyed by [PrayerLogProxy.dateKey].
  final Map<String, Set<String>> donePrayers;

  /// Today's times, to tell prayers still to come from missed ones.
  final PrayerModel? todayPrayer;
  final int streak;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  const PrayerHistoryCard({
    super.key,
    required this.days,
    required this.prayers,
    required this.donePrayers,
    required this.todayPrayer,
    required this.streak,
    required this.selectedDate,
    required this.onDaySelected,
  });

  /// Whether [prayer] has started by [now]. Without today's times every
  /// prayer counts as started.
  bool _hasStarted(String prayer, DateTime now) {
    final time = todayPrayer?.toJson()[prayer] as String? ?? '';
    final parts = time.split(':');
    if (parts.length != 2) return true;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute <= now.hour * 60 + now.minute;
  }

  _CellState _stateOf(DateTime day, String prayer, DateTime now) {
    if (donePrayers[PrayerLogProxy.dateKey(day)]?.contains(prayer) ?? false) {
      return _CellState.done;
    }
    if (DateUtils.isSameDay(day, now) && !_hasStarted(prayer, now)) {
      return _CellState.upcoming;
    }
    return _CellState.missed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final languageCode = context.watch<LocaleProvider>().locale?.languageCode;
    final now = DateTime.now();

    final states = {
      for (final day in days)
        day: [for (final prayer in prayers) _stateOf(day, prayer, now)],
    };

    /// Prayers still to come do not count against the rate.
    final cells = states.values.expand((day) => day);
    final dueCount = cells.where((s) => s != _CellState.upcoming).length;
    final doneCount = cells.where((s) => s == _CellState.done).length;
    final rate = dueCount == 0 ? 0 : (doneCount * 100 / dueCount).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.prayerHistory ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n?.historyRate(rate, days.length) ?? '',
                      maxLines: 2,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StreakPill(label: l10n?.streakDays(streak) ?? '$streak'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PrayerLabels(prayers: prayers),
              for (final day in days)
                Expanded(
                  child: _DayColumn(
                    weekday: DateFormat.E(languageCode).format(day),
                    dayOfMonth: day.day,
                    states: states[day]!,
                    isToday: DateUtils.isSameDay(day, now),
                    isSelected: DateUtils.isSameDay(day, selectedDate),
                    onTap: () => onDaySelected(day),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final String label;

  const _StreakPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 16,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared sizes so the labels line up with the cells of each day column.
const double _headerHeight = 40;
const double _cellHeight = 26;

class _PrayerLabels extends StatelessWidget {
  final List<String> prayers;

  const _PrayerLabels({required this.prayers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: _headerHeight + 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final prayer in prayers)
            SizedBox(
              height: _cellHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  PrayerProxy().getPrayerLabel(context, prayer),
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  final String weekday;
  final int dayOfMonth;
  final List<_CellState> states;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayColumn({
    required this.weekday,
    required this.dayOfMonth,
    required this.states,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final headerColor = isToday
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              children: [
                SizedBox(
                  height: _headerHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          weekday,
                          maxLines: 1,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: headerColor,
                          ),
                        ),
                      ),
                      Text(
                        '$dayOfMonth',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                for (final state in states)
                  SizedBox(
                    height: _cellHeight,
                    child: Center(child: _Cell(state: state)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final _CellState state;

  const _Cell({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: state == _CellState.upcoming ? 6 : 18,
      height: state == _CellState.upcoming ? 6 : 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (state) {
          _CellState.done => colorScheme.primary,
          _CellState.missed => Colors.transparent,
          _CellState.upcoming => colorScheme.outlineVariant,
        },
        border: state == _CellState.missed
            ? Border.all(color: colorScheme.outlineVariant, width: 1.5)
            : null,
      ),
      child: state == _CellState.done
          ? Icon(Icons.check_rounded, size: 12, color: colorScheme.onPrimary)
          : null,
    );
  }
}
