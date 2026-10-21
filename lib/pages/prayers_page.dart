import 'package:deenly/components/prayer_sync_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/prayers/prayer_date_header.dart';
import 'package:deenly/pages/prayers/prayer_history_card.dart';
import 'package:deenly/pages/prayers/prayer_schedule_card.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/proxys/prayer_log_proxy.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prayers tab: the schedule of any day of the cached year, where each
/// prayer can be marked as done, that day's progress and a recap of the
/// last days.
class PrayersPage extends StatefulWidget {
  const PrayersPage({super.key});

  @override
  State<PrayersPage> createState() => PrayersPageState();
}

class PrayersPageState extends State<PrayersPage>
    with SingleTickerProviderStateMixin {
  /// Minimum fling speed (px/s) that moves to another day.
  static const double _swipeVelocity = 300;

  static const List<String> _trackedPrayers = PrayerLogProxy.trackedPrayers;

  /// Days shown in the history card, today included.
  static const int _historyDays = 7;

  final PrayerProxy _prayerProxy = PrayerProxy();
  final PrayerLogProxy _prayerLogProxy = PrayerLogProxy();

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late DateTime _date = _today();
  PrayerModel? _prayerModel;
  Set<String> _donePrayers = {};
  String _location = '';
  bool _isLoading = true;

  Map<String, Set<String>> _history = {};
  PrayerModel? _todayPrayer;
  int _streak = 0;

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
    _loadHistory();
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
  void reload() {
    _load(_followsToday ? _today() : _date);
    _loadHistory();
  }

  List<DateTime> get _historyRange => [
    for (var i = _historyDays - 1; i >= 0; i--)
      DateUtils.addDaysToDate(_today(), -i),
  ];

  Future<void> _loadHistory() async {
    final range = _historyRange;
    try {
      final history = await _prayerLogProxy.getDonePrayersBetween(
        range.first,
        range.last,
      );
      final streak = await _prayerLogProxy.getStreak(
        range.last,
        _trackedPrayers,
      );
      final todayPrayer = await _prayerProxy.getTodayPrayer();
      if (!mounted) return;
      setState(() {
        _history = history;
        _streak = streak;
        _todayPrayer = todayPrayer;
      });
    } catch (e, st) {
      debugPrint('Loading prayer history failed: $e\n$st');
    }
  }

  Future<void> _load(DateTime date) async {
    final loadId = ++_loadId;
    setState(() {
      _date = date;
      _followsToday = DateUtils.isSameDay(date, DateTime.now());
    });

    PrayerModel? prayerModel;
    String location = _location;
    Set<String> donePrayers = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      location = prefs.getString(PrayerSyncHelper.keyLocationName) ?? '';
      prayerModel = await _prayerProxy.getPrayerForDate(date);
      donePrayers = await _prayerLogProxy.getDonePrayers(date);
    } catch (e, st) {
      debugPrint('Loading prayer schedule failed: $e\n$st');
    }

    if (!mounted || loadId != _loadId) return;
    setState(() {
      _prayerModel = prayerModel;
      _donePrayers = donePrayers;
      _location = location;
      _isLoading = false;
    });
  }

  /// Why no prayer of the shown day can be marked: it is in the future or
  /// too far back. Null when it can.
  String? _trackLockedMessage(AppLocalizations? l10n) {
    final today = _today();
    if (_date.isAfter(today)) return l10n?.prayerNotYet ?? '';
    final oldest = DateUtils.addDaysToDate(today, -PrayerLogProxy.editableDays);
    if (_date.isBefore(oldest)) {
      return l10n?.prayerTrackLocked(PrayerLogProxy.editableDays) ?? '';
    }
    return null;
  }

  /// Updates the check right away and rolls it back if saving fails.
  Future<void> _setDone(String prayer, bool isDone) async {
    final date = _date;
    void apply(bool value) => setState(() {
      _donePrayers = value
          ? {..._donePrayers, prayer}
          : (Set.of(_donePrayers)..remove(prayer));
    });

    apply(isDone);
    try {
      await _prayerLogProxy.setDone(date, prayer, isDone);
    } catch (e, st) {
      debugPrint('Saving prayer log failed: $e\n$st');
      if (mounted && DateUtils.isSameDay(date, _date)) apply(!isDone);
    }
    await _loadHistory();
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
        isFriday: _date.weekday == DateTime.friday,
        donePrayers: _donePrayers,
        lockedMessage: _trackLockedMessage(AppLocalizations.of(context)),
        onDoneChanged: _setDone,
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
        completedCount: _trackedPrayers.where(_donePrayers.contains).length,
        totalCount: _trackedPrayers.length,
        onPrevious: canGoBack ? () => _changeDay(-1) : null,
        onNext: canGoForward ? () => _changeDay(1) : null,
        onPickDate: _pickDate,
        onToday: () => _load(_today()),
      ),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: schedule,
      ),
      PrayerHistoryCard(
        days: _historyRange,
        prayers: _trackedPrayers,
        donePrayers: _history,
        todayPrayer: _todayPrayer,
        streak: _streak,
        selectedDate: _date,
        onDaySelected: (day) {
          if (!day.isBefore(_firstDate)) _load(day);
        },
      ),
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
