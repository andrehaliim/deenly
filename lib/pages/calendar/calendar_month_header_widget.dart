import 'package:deenly/components/calendar_provider.dart';
import 'package:deenly/components/hijri_format.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/calendar_day_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Month title in the main calendar, the matching range in the other
/// calendar below it, and arrows to move between months.
class CalendarMonthHeader extends StatelessWidget {
  final List<CalendarDayModel> days;

  const CalendarMonthHeader({super.key, required this.days});

  String _hijriRange(AppLocalizations? l10n) {
    final first = days.first.hijri;
    final last = days.last.hijri;
    if (first.month == last.month) {
      return HijriFormat.monthYear(l10n, first.year, first.month);
    }
    final start = first.year == last.year
        ? HijriFormat.monthName(l10n, first.month)
        : HijriFormat.monthYear(l10n, first.year, first.month);
    return '$start – ${HijriFormat.monthYear(l10n, last.year, last.month)}';
  }

  String _gregorianRange(String languageCode) {
    final first = days.first.date;
    final last = days.last.date;
    final monthYear = DateFormat.yMMMM(languageCode);
    if (first.month == last.month) return monthYear.format(first);
    final start = first.year == last.year
        ? DateFormat.MMMM(languageCode).format(first)
        : monthYear.format(first);
    return '$start – ${monthYear.format(last)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final provider = context.read<CalendarProvider>();
    final isHijriPrimary = provider.isHijriPrimary;

    final title = isHijriPrimary
        ? HijriFormat.monthYear(
            l10n,
            provider.hijriMonth.year,
            provider.hijriMonth.month,
          )
        : DateFormat.yMMMM(languageCode).format(provider.gregorianMonth);
    final subtitle = isHijriPrimary
        ? _gregorianRange(languageCode)
        : _hijriRange(l10n);

    return Row(
      children: [
        IconButton(
          tooltip: l10n?.calendarPreviousMonth,
          onPressed: provider.showPreviousMonth,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n?.calendarNextMonth,
          onPressed: provider.showNextMonth,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
