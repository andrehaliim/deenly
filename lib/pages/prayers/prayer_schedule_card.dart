import 'dart:async';

import 'package:deenly/components/app_colors.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/prayers/prayer_icon.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full prayer schedule of one day as a vertical timeline. For today the
/// rail fills up to the current time, the current prayer is highlighted,
/// the next one counts down and the times already passed are dimmed.
/// Tapping a prayer marks it as done.
class PrayerScheduleCard extends StatefulWidget {
  final PrayerModel prayerModel;
  final bool isToday;

  /// Dhuhr is replaced by the Friday prayer.
  final bool isFriday;
  final Set<String> donePrayers;

  /// Why no prayer of this day can be marked, or null if they can.
  final String? lockedMessage;
  final void Function(String prayer, bool isDone) onDoneChanged;

  const PrayerScheduleCard({
    super.key,
    required this.prayerModel,
    required this.isToday,
    required this.isFriday,
    required this.donePrayers,
    required this.lockedMessage,
    required this.onDoneChanged,
  });

  @override
  State<PrayerScheduleCard> createState() => _PrayerScheduleCardState();
}

class _PrayerScheduleCardState extends State<PrayerScheduleCard> {
  /// Schedule rows in order. Imsak and Sunrise are info only: they have
  /// no adhan and are never the current prayer.
  static const List<String> _rows = [
    'Imsak',
    'Fajr',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];
  static const Set<String> _infoRows = {'Imsak', 'Sunrise'};

  /// Ticks every second but only rebuilds when the minute changes.
  static const Duration _tickInterval = Duration(seconds: 1);

  late DateTime _now;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _ticker = Timer.periodic(_tickInterval, (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _tick() {
    final now = DateTime.now();
    if (now.minute == _now.minute && now.hour == _now.hour) return;
    setState(() => _now = now);
  }

  /// Minutes since midnight of [time] ("HH:mm"), or null if unparsable.
  static int? _minutesOf(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  String _formatDuration(AppLocalizations l10n, int minutes) {
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return hours > 0
        ? l10n.durationHoursMinutes(hours, rest)
        : l10n.durationMinutes(rest);
  }

  /// Marks [prayer] when allowed, otherwise tells why it is locked. Today's
  /// prayers unlock once their time has come.
  void _onPrayerTap(String prayer, {required bool hasStarted}) {
    final l10n = AppLocalizations.of(context);
    final lockedMessage =
        widget.lockedMessage ??
        (widget.isToday && !hasStarted ? l10n?.prayerNotYet : null);

    if (lockedMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(lockedMessage)));
      return;
    }
    HapticFeedback.lightImpact();
    widget.onDoneChanged(prayer, !widget.donePrayers.contains(prayer));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final timings = widget.prayerModel.toJson();

    final rows = [
      for (final row in _rows)
        if (_minutesOf(timings[row] as String? ?? '') case final minutes?)
          (prayer: row, minutes: minutes),
    ];

    /// Status only makes sense for today. The current prayer is the last
    /// one started; Fajr ends at sunrise, leaving no current prayer until
    /// Dhuhr.
    String? current;
    String? next;
    final nowMinutes = widget.isToday ? _now.hour * 60 + _now.minute : -1;
    if (widget.isToday) {
      for (final row in rows) {
        if (row.prayer == 'Imsak') continue;
        if (row.minutes <= nowMinutes) {
          current = row.prayer == 'Sunrise' ? null : row.prayer;
        } else if (!_infoRows.contains(row.prayer)) {
          next ??= row.prayer;
        }
      }
    }

    /// How much of the rail between row [i] and the row after it is filled
    /// by the time elapsed today, from 0 to 1.
    double gapFill(int i) {
      if (!widget.isToday || i < 0 || i >= rows.length - 1) return 0;
      final from = rows[i].minutes;
      final to = rows[i + 1].minutes;
      if (nowMinutes >= to) return 1;
      if (nowMinutes <= from || to <= from) return 0;
      return (nowMinutes - from) / (to - from);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              l10n?.prayerTimes ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          for (final (i, row) in rows.indexed)
            _TimelineRow(
              prayer: row.prayer,
              label: switch (row.prayer) {
                'Imsak' => l10n?.imsak ?? row.prayer,
                'Sunrise' => l10n?.sunrise ?? row.prayer,
                'Dhuhr' when widget.isFriday => l10n?.jumuah ?? row.prayer,
                _ => PrayerProxy().getPrayerLabel(context, row.prayer),
              },
              time: timings[row.prayer] as String,
              isInfo: _infoRows.contains(row.prayer),
              status: row.prayer == current
                  ? l10n?.prayerNow
                  : row.prayer == next && l10n != null
                  ? l10n.prayerStartsIn(
                      _formatDuration(l10n, row.minutes - nowMinutes),
                    )
                  : null,
              isCurrent: row.prayer == current,
              isNext: row.prayer == next,
              isPassed: widget.isToday && row.minutes <= nowMinutes,
              hasLineAbove: i > 0,
              hasLineBelow: i < rows.length - 1,

              /// Each gap is split between the lower half of one row's rail
              /// and the upper half of the next one.
              fillAbove: (gapFill(i - 1) * 2 - 1).clamp(0.0, 1.0),
              fillBelow: (gapFill(i) * 2).clamp(0.0, 1.0),
              isDone: widget.donePrayers.contains(row.prayer),
              isLocked:
                  widget.lockedMessage != null ||
                  (widget.isToday && row.minutes > nowMinutes),
              onTap: () => _onPrayerTap(
                row.prayer,
                hasStarted: row.minutes <= nowMinutes,
              ),
            ),
        ],
      ),
    );
  }
}

/// One stop of the timeline: time on the left, the rail with its dot, and
/// the prayer itself. Info rows (Imsak, Sunrise) are smaller and have no
/// done check.
class _TimelineRow extends StatelessWidget {
  static const double _timeWidth = 48;
  static const double _railWidth = 28;
  static const Duration _duration = Duration(milliseconds: 300);

  final String prayer;
  final String label;
  final String time;
  final bool isInfo;
  final String? status;
  final bool isCurrent;
  final bool isNext;
  final bool isPassed;
  final bool hasLineAbove;
  final bool hasLineBelow;
  final double fillAbove;
  final double fillBelow;
  final bool isDone;
  final bool isLocked;
  final VoidCallback onTap;

  const _TimelineRow({
    required this.prayer,
    required this.label,
    required this.time,
    required this.isInfo,
    required this.status,
    required this.isCurrent,
    required this.isNext,
    required this.isPassed,
    required this.hasLineAbove,
    required this.hasLineBelow,
    required this.fillAbove,
    required this.fillBelow,
    required this.isDone,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    /// The current prayer has started too, but stays fully visible.
    final isDimmed = isPassed && !isCurrent;
    final timeColor = isCurrent || isNext
        ? colorScheme.primary
        : isInfo || isDimmed
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;
    final timeStyle = isInfo
        ? theme.textTheme.labelMedium
        : theme.textTheme.titleSmall;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _timeWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                duration: _duration,
                opacity: isDimmed ? 0.6 : 1,
                child: Text(
                  time,
                  style: timeStyle?.copyWith(
                    fontWeight: isInfo ? FontWeight.w500 : FontWeight.bold,
                    color: timeColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: _railWidth,
            child: CustomPaint(
              painter: _RailPainter(
                activeColor: colorScheme.primary,
                trackColor: colorScheme.outlineVariant,
                surfaceColor: colorScheme.surfaceContainerLowest,
                nextColor: colorScheme.secondary,
                isInfo: isInfo,
                isCurrent: isCurrent,
                isNext: isNext,
                isPassed: isPassed,
                hasLineAbove: hasLineAbove,
                hasLineBelow: hasLineBelow,
                fillAbove: fillAbove,
                fillBelow: fillBelow,
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: _duration,
              opacity: isDimmed ? 0.55 : 1,
              child: isInfo
                  ? _InfoContent(prayer: prayer, label: label)
                  : _PrayerContent(
                      prayer: prayer,
                      label: label,
                      status: status,
                      isCurrent: isCurrent,
                      isNext: isNext,
                      isDone: isDone,
                      isLocked: isLocked,
                      onTap: onTap,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerContent extends StatelessWidget {
  final String prayer;
  final String label;
  final String? status;
  final bool isCurrent;
  final bool isNext;
  final bool isDone;
  final bool isLocked;
  final VoidCallback onTap;

  const _PrayerContent({
    required this.prayer,
    required this.label,
    required this.status,
    required this.isCurrent,
    required this.isNext,
    required this.isDone,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();

    final foreground = isCurrent
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final accent = isCurrent ? colorScheme.onPrimary : colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        /// Same gradient as the hero cards, so "now" reads as one family.
        gradient: isCurrent ? appColors?.heroGradient : null,
        color: isCurrent
            ? null
            : isNext
            ? colorScheme.primaryContainer.withValues(alpha: 0.45)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNext
              ? colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: appColors?.heroShadow ?? colorScheme.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: isCurrent ? 0.15 : 0.08),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(prayerIconOf(prayer), size: 18, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: foreground,
                        ),
                      ),
                      if (status case final status?)
                        Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? colorScheme.secondaryFixedDim
                                : colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Semantics(
                  checked: isDone,
                  label: label,
                  child: _DoneCheck(
                    isDone: isDone,
                    isLocked: isLocked,
                    onAccent: isCurrent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round checkbox of a prayer: an empty ring while not done, a filled check
/// once done. [onAccent] draws it on the current prayer's gradient.
class _DoneCheck extends StatelessWidget {
  final bool isDone;
  final bool isLocked;
  final bool onAccent;

  const _DoneCheck({
    required this.isDone,
    required this.isLocked,
    required this.onAccent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = onAccent ? colorScheme.onPrimary : colorScheme.primary;
    final onFill = onAccent ? colorScheme.primary : colorScheme.onPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? accent : Colors.transparent,
        border: Border.all(
          color: accent.withValues(
            alpha: isDone
                ? 1
                : isLocked
                ? 0.25
                : 0.6,
          ),
          width: 2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: isDone
            ? Icon(
                Icons.check_rounded,
                key: const ValueKey(true),
                size: 18,
                color: onFill,
              )
            : const SizedBox.shrink(key: ValueKey(false)),
      ),
    );
  }
}

class _InfoContent extends StatelessWidget {
  final String prayer;
  final String label;

  const _InfoContent({required this.prayer, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Icon(prayerIconOf(prayer), size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints one row's piece of the timeline rail: the line halves above and
/// below the dot, each filled up to its share of the time elapsed, and the
/// dot itself.
class _RailPainter extends CustomPainter {
  static const double _lineWidth = 2;

  final Color activeColor;
  final Color trackColor;
  final Color surfaceColor;
  final Color nextColor;
  final bool isInfo;
  final bool isCurrent;
  final bool isNext;
  final bool isPassed;
  final bool hasLineAbove;
  final bool hasLineBelow;
  final double fillAbove;
  final double fillBelow;

  const _RailPainter({
    required this.activeColor,
    required this.trackColor,
    required this.surfaceColor,
    required this.nextColor,
    required this.isInfo,
    required this.isCurrent,
    required this.isNext,
    required this.isPassed,
    required this.hasLineAbove,
    required this.hasLineBelow,
    required this.fillAbove,
    required this.fillBelow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final line = Paint()
      ..strokeWidth = _lineWidth
      ..strokeCap = StrokeCap.round;

    void segment(double fromY, double toY, double fill) {
      line.color = trackColor;
      canvas.drawLine(Offset(center.dx, fromY), Offset(center.dx, toY), line);
      if (fill <= 0) return;
      line.color = activeColor;
      canvas.drawLine(
        Offset(center.dx, fromY),
        Offset(center.dx, fromY + (toY - fromY) * fill),
        line,
      );
    }

    if (hasLineAbove) segment(0, center.dy, fillAbove);
    if (hasLineBelow) segment(center.dy, size.height, fillBelow);

    if (isCurrent) {
      canvas.drawCircle(
        center,
        11,
        Paint()..color = activeColor.withValues(alpha: 0.18),
      );
      canvas.drawCircle(center, 7, Paint()..color = activeColor);
      canvas.drawCircle(center, 3, Paint()..color = surfaceColor);
      return;
    }

    final radius = isInfo ? 3.5 : 5.5;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = isPassed ? activeColor : surfaceColor,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isNext ? 2.5 : _lineWidth
        ..color = isNext
            ? nextColor
            : isPassed
            ? activeColor
            : trackColor,
    );
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) =>
      oldDelegate.activeColor != activeColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.surfaceColor != surfaceColor ||
      oldDelegate.nextColor != nextColor ||
      oldDelegate.isInfo != isInfo ||
      oldDelegate.isCurrent != isCurrent ||
      oldDelegate.isNext != isNext ||
      oldDelegate.isPassed != isPassed ||
      oldDelegate.hasLineAbove != hasLineAbove ||
      oldDelegate.hasLineBelow != hasLineBelow ||
      oldDelegate.fillAbove != fillAbove ||
      oldDelegate.fillBelow != fillBelow;
}
