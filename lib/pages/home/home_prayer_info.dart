import 'dart:async';

import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/quran/eight_point_star_painter.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePrayerInfo extends StatefulWidget {
  final String location;
  final PrayerModel prayerModel;
  final VoidCallback onRefreshLocation;

  const HomePrayerInfo({
    super.key,
    required this.location,
    required this.prayerModel,
    required this.onRefreshLocation,
  });

  @override
  State<HomePrayerInfo> createState() => _HomePrayerInfoState();
}

class _HomePrayerInfoState extends State<HomePrayerInfo> {
  static const List<String> _prayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  /// Ticks every second but only rebuilds when the minute changes, so the
  /// clock flips on time without rebuilding every second.
  static const Duration _tickInterval = Duration(seconds: 1);

  late Map<String, String> _next;
  late DateTime _now;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _next = _computeNextPrayer();
    _ticker = Timer.periodic(_tickInterval, (_) => _tick());
  }

  @override
  void didUpdateWidget(HomePrayerInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prayerModel != widget.prayerModel) {
      setState(() => _next = _computeNextPrayer());
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Map<String, String> _computeNextPrayer() =>
      PrayerProxy().getNextPrayer(widget.prayerModel.toJson());

  void _tick() {
    final now = DateTime.now();
    if (now.minute == _now.minute && now.hour == _now.hour) return;
    setState(() {
      _now = now;
      _next = _computeNextPrayer();
    });
  }

  /// Time left until [time] ("HH:mm"); a time already passed today is
  /// tomorrow's (Fajr after Isha).
  Duration _timeUntil(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final now = DateTime(
      _now.year,
      _now.month,
      _now.day,
      _now.hour,
      _now.minute,
    );
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (!target.isAfter(now)) target = target.add(const Duration(days: 1));
    return target.difference(now);
  }

  String _formatDuration(AppLocalizations l10n, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return hours > 0
        ? l10n.durationHoursMinutes(hours, minutes)
        : l10n.durationMinutes(minutes);
  }

  String _gregorianDate(String? languageCode) {
    try {
      final date = DateFormat('dd-MM-yyyy').parse(widget.prayerModel.date);
      return DateFormat('EEEE, d MMMM yyyy', languageCode).format(date);
    } catch (_) {
      return widget.prayerModel.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onCard = colorScheme.onPrimary;
    final accent = colorScheme.secondaryFixedDim;
    final l10n = AppLocalizations.of(context);
    final languageCode = context.watch<LocaleProvider>().locale?.languageCode;
    final model = widget.prayerModel;
    final timings = model.toJson();
    final nextPrayer = _next['nextPrayer'] ?? '';
    final nextTime = _next['nextTime'] ?? '';

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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _LocationChip(
                    location: widget.location,
                    onTap: widget.onRefreshLocation,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${model.hijriDate} ${model.hijriMonth} ${model.hijriYear}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onCard,
                  ),
                ),
                Text(
                  _gregorianDate(languageCode),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: onCard.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DateFormat('HH:mm').format(_now),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onCard,
                      height: 1.1,
                    ),
                  ),
                ),
                if (l10n != null && nextTime.isNotEmpty)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: l10n.nextPrayerIn(
                            PrayerProxy().getPrayerLabel(context, nextPrayer),
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: _formatDuration(l10n, _timeUntil(nextTime)),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onCard.withValues(alpha: 0.85),
                    ),
                  ),
                const SizedBox(height: 18),
                Divider(color: onCard.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final prayer in _prayers)
                      Expanded(
                        child: _PrayerTimeItem(
                          prayer: prayer,
                          time: timings[prayer] ?? '',
                          isNext: prayer == nextPrayer,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String location;
  final VoidCallback onTap;

  const _LocationChip({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCard = theme.colorScheme.onPrimary;

    return Material(
      color: onCard.withValues(alpha: 0.15),
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
              const SizedBox(width: 6),
              Icon(
                Icons.refresh_rounded,
                size: 14,
                color: onCard.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerTimeItem extends StatelessWidget {
  final String prayer;
  final String time;
  final bool isNext;

  const _PrayerTimeItem({
    required this.prayer,
    required this.time,
    required this.isNext,
  });

  static IconData _iconOf(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.wb_twilight_rounded;
      case 'Dhuhr':
        return Icons.light_mode_outlined;
      case 'Asr':
        return Icons.filter_drama_outlined;
      case 'Maghrib':
        return Icons.nights_stay_outlined;
      default:
        return Icons.bedtime_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCard = theme.colorScheme.onPrimary;
    final color = isNext
        ? theme.colorScheme.secondaryFixedDim
        : onCard.withValues(alpha: 0.85);
    final weight = isNext ? FontWeight.bold : FontWeight.w500;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isNext ? onCard.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              PrayerProxy().getPrayerLabel(context, prayer),
              maxLines: 1,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: weight,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Icon(_iconOf(prayer), size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            time,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: weight,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
