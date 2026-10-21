import 'package:deenly/components/prayer_sync_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/home/home_prayer_progress.dart';
import 'package:deenly/pages/prayers/prayer_date_header.dart';
import 'package:deenly/pages/prayers/prayer_schedule_card.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prayers tab: the schedule of any day of the cached year, with the daily
/// prayer progress below it.
class PrayersPage extends StatefulWidget {
  const PrayersPage({super.key});

  @override
  State<PrayersPage> createState() => PrayersPageState();
}

class PrayersPageState extends State<PrayersPage>
    with SingleTickerProviderStateMixin {
  /// Minimum fling speed (px/s) that moves to another day.
  static const double _swipeVelocity = 300;

  final PrayerProxy _prayerProxy = PrayerProxy();

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late DateTime _date = _today();
  PrayerModel? _prayerModel;
  String _location = '';
  bool _isLoading = true;

  /// Whether the shown day was today when loaded, so [reload] can move on
  /// to the new today after midnight.
  bool _followsToday = true;

  /// Bumped on every load so a slow, older load cannot overwrite a newer
  /// one when days are switched quickly.
  int _loadId = 0;

  @override
  void initState() {
    super.initState();
    _entranceController.forward();
    _load(_date);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Only the current year is cached (see [PrayerProxy.fetchYearlyPrayer]).
  DateTime get _firstDate => DateTime(DateTime.now().year);
  DateTime get _lastDate => DateTime(DateTime.now().year, 12, 31);

  bool get _isToday => DateUtils.isSameDay(_date, DateTime.now());

  /// Re-reads the cache, e.g. after a sync or saved adjustments. Viewing
  /// today keeps following today when the day has changed.
  void reload() => _load(_followsToday ? _today() : _date);

  Future<void> _load(DateTime date) async {
    final loadId = ++_loadId;
    setState(() {
      _date = date;
      _followsToday = DateUtils.isSameDay(date, DateTime.now());
    });

    PrayerModel? prayerModel;
    String location = _location;
    try {
      final prefs = await SharedPreferences.getInstance();
      location = prefs.getString(PrayerSyncHelper.keyLocationName) ?? '';
      prayerModel = await _prayerProxy.getPrayerForDate(date);
    } catch (e, st) {
      debugPrint('Loading prayer schedule failed: $e\n$st');
    }

    if (!mounted || loadId != _loadId) return;
    setState(() {
      _prayerModel = prayerModel;
      _location = location;
      _isLoading = false;
    });
  }

  void _changeDay(int days) {
    final date = DateUtils.addDaysToDate(_date, days);
    if (date.isBefore(_firstDate) || date.isAfter(_lastDate)) return;
    _load(date);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: _firstDate,
      lastDate: _lastDate,
      currentDate: DateTime.now(),
    );
    if (date != null && mounted) _load(date);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _swipeVelocity) return;
    _changeDay(velocity < 0 ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    final prayerModel = _prayerModel;
    final canGoBack = _date.isAfter(_firstDate);
    final canGoForward = _date.isBefore(_lastDate);

    final Widget schedule;
    if (_isLoading) {
      schedule = const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (prayerModel != null) {
      schedule = PrayerScheduleCard(
        key: ValueKey(_date),
        prayerModel: prayerModel,
        isToday: _isToday,
      );
    } else {
      schedule = _EmptySchedule(key: ValueKey(_date));
    }

    final sections = [
      PrayerDateHeader(
        date: _date,
        prayerModel: prayerModel,
        location: _location,
        isToday: _isToday,
        onPrevious: canGoBack ? () => _changeDay(-1) : null,
        onNext: canGoForward ? () => _changeDay(1) : null,
        onPickDate: _pickDate,
        onToday: () => _load(_today()),
      ),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: schedule,
      ),
      const HomePrayerProgress(),
    ];

    return GestureDetector(
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              StaggeredEntrance(
                animation: _entranceController,
                index: i,
                child: sections[i],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 36,
            color: colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)?.prayerScheduleEmpty ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
