import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/quran/eight_point_star_painter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Hero card of the prayers tab: location, the selected date in Hijri and
/// Gregorian, buttons to move between days and that day's prayer progress.
class PrayerDateHeader extends StatelessWidget {
  final DateTime date;
  final PrayerModel? prayerModel;
  final String location;
  final bool isToday;
  final int completedCount;
  final int totalCount;

  /// Null when there is no day to move to (outside the cached year).
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onPickDate;
  final VoidCallback onToday;

  const PrayerDateHeader({
    super.key,
    required this.date,
    required this.prayerModel,
    required this.location,
    required this.isToday,
    required this.completedCount,
    required this.totalCount,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onCard = colorScheme.onPrimary;
    final l10n = AppLocalizations.of(context);
    final languageCode = context.watch<LocaleProvider>().locale?.languageCode;
    final model = prayerModel;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            Color.alphaBlend(
              colorScheme.secondary.withValues(alpha: 0.35),
              colorScheme.primary,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
          opacity: 0.12,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: CustomPaint(
              size: const Size.square(180),
              painter: EightPointStarPainter(
                color: onCard.withValues(alpha: 0.08),
                strokeWidth: 10,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      if (location.isNotEmpty)
                        Flexible(child: _LocationChip(location: location)),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: isToday
                            ? const SizedBox.shrink()
                            : _TodayButton(
                                label: l10n?.backToToday ?? '',
                                onTap: onToday,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _NavButton(
                      icon: Icons.chevron_left_rounded,
                      tooltip: l10n?.previousDay,
                      onPressed: onPrevious,
                    ),
                    Expanded(
                      child: Tooltip(
                        message: l10n?.chooseDate ?? '',
                        child: InkWell(
                          onTap: onPickDate,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Column(
                                key: ValueKey(date),
                                children: [
                                  Text(
                                    model != null
                                        ? '${model.hijriDate} '
                                              '${model.hijriMonth} '
                                              '${model.hijriYear}'
                                        : '-',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: onCard,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          DateFormat(
                                            'EEEE, d MMMM yyyy',
                                            languageCode,
                                          ).format(date),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color: onCard.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.expand_more_rounded,
                                        size: 16,
                                        color: colorScheme.secondaryFixedDim,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _NavButton(
                      icon: Icons.chevron_right_rounded,
                      tooltip: l10n?.nextDay,
                      onPressed: onNext,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _DayProgress(
                    completedCount: completedCount,
                    totalCount: totalCount,
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

class _DayProgress extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const _DayProgress({required this.completedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onCard = colorScheme.onPrimary;
    final accent = colorScheme.secondaryFixedDim;
    final l10n = AppLocalizations.of(context);
    final isComplete = totalCount > 0 && completedCount >= totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(color: onCard.withValues(alpha: 0.2), height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n?.prayerProgress ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: onCard.withValues(alpha: 0.85),
                ),
              ),
            ),
            if (isComplete) ...[
              Icon(Icons.check_circle_rounded, size: 16, color: accent),
              const SizedBox(width: 4),
            ],
            Text(
              '$completedCount/$totalCount ${l10n?.completed ?? ''}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(end: totalCount == 0 ? 0 : completedCount / totalCount),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: onCard.withValues(alpha: 0.2),
                color: accent,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final onCard = Theme.of(context).colorScheme.onPrimary;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      color: onCard,
      disabledColor: onCard.withValues(alpha: 0.3),
      style: IconButton.styleFrom(
        backgroundColor: onCard.withValues(alpha: 0.12),
        disabledBackgroundColor: onCard.withValues(alpha: 0.05),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String location;

  const _LocationChip({required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCard = theme.colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(
        color: onCard.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: theme.colorScheme.secondaryFixedDim,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: onCard,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TodayButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.secondaryFixedDim,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.today_rounded,
                size: 16,
                color: colorScheme.onSecondaryFixed,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryFixed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
