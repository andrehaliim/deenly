import 'package:deenly/components/app_colors.dart';
import 'package:deenly/models/calendar_day_model.dart';
import 'package:deenly/models/islamic_event_model.dart';
import 'package:deenly/pages/calendar/calendar_marker_color.dart';
import 'package:flutter/material.dart';

/// One day: the main calendar's date large, the other one small, and dots
/// for holidays and fasting below.
class CalendarDayCell extends StatelessWidget {
  final CalendarDayModel day;
  final bool isToday;
  final bool isHijriPrimary;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isHijriPrimary,
    required this.onTap,
  });

  static const double height = 58;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();
    final fasting = day.fasting;
    final primaryNumber = isHijriPrimary ? day.hijri.day : day.date.day;
    final secondaryNumber = isHijriPrimary ? day.date.day : day.hijri.day;

    final Color numberColor;
    if (isToday) {
      numberColor = colorScheme.onPrimary;
    } else if (day.hasHoliday) {
      numberColor = CalendarMarkerColor.holiday(theme);
    } else if (day.date.weekday == DateTime.friday) {
      numberColor = colorScheme.primary;
    } else {
      numberColor = colorScheme.onSurface;
    }

    return SizedBox(
      height: height,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isToday ? appColors?.heroGradient : null,
            color: isToday
                ? colorScheme.primary
                : day.hasHoliday
                ? colorScheme.secondary.withValues(alpha: 0.12)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$primaryNumber',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: numberColor,
                  height: 1.1,
                ),
              ),
              Text(
                '$secondaryNumber',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  height: 1.1,
                  color: isToday
                      ? colorScheme.onPrimary.withValues(alpha: 0.8)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (day.hasHoliday)
                      _Dot(
                        color: isToday
                            ? colorScheme.secondaryFixed
                            : CalendarMarkerColor.holiday(theme),
                      ),
                    if (fasting != null)
                      _Dot(
                        color: !isToday
                            ? CalendarMarkerColor.ofFasting(theme, fasting)
                            : fasting == FastingType.forbidden
                            ? colorScheme.errorContainer
                            : colorScheme.onPrimary,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
