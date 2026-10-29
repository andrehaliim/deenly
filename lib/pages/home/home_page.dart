import 'dart:async';

import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/prayer_sync_helper.dart';
import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/dzikir_period_model.dart';
import 'package:deenly/models/hadith_model.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/dzikir/dzikir_detail_page.dart';
import 'package:deenly/pages/home/home_approximate_notice.dart';
import 'package:deenly/pages/home/home_city_picker_dialog.dart';
import 'package:deenly/pages/home/home_dzikir_reminder.dart';
import 'package:deenly/pages/home/home_hadith_skeleton.dart';
import 'package:deenly/pages/home/home_hadith_widget.dart';
import 'package:deenly/pages/home/home_overview_card.dart';
import 'package:deenly/pages/home/home_prayer_error.dart';
import 'package:deenly/pages/home/home_prayer_info.dart';
import 'package:deenly/pages/home/home_prayer_skeleton.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/proxys/dzikir_proxy.dart';
import 'package:deenly/proxys/hadith_proxy.dart';
import 'package:deenly/proxys/prayer_log_proxy.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  /// Opens the prayers tab, from the progress chip.
  final VoidCallback onOpenPrayers;

  const HomePage({super.key, required this.onOpenPrayers});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final PrayerProxy _prayerProxy = PrayerProxy();
  final HadithProxy _hadithProxy = HadithProxy();
  bool _isGettingPrayerData = true;
  bool _isGettingHadithData = true;
  String? _location;
  bool _isApproximate = false;
  PrayerModel? _prayerModel;
  HadithModel? _hadithModel;
  ({int completed, int total, int streak})? _progress;
  bool _isHadithExpanded = false;
  DzikirPeriod? _dzikirPeriod;
  Timer? _dzikirTicker;

  /// Shortest viewport, before text scaling, that fits the prayer card,
  /// menu and a couple of hadith lines; shorter screens scroll instead of
  /// fitting the collapsed page to one screen.
  static const double _minFillHeight = 600;

  /// Room the approximate location notice takes above the card.
  static const double _noticeHeight = 110;

  /// How often to check whether a dzikir window opened or closed.
  static const Duration _dzikirCheckInterval = Duration(seconds: 30);

  static const double _sectionSpacing = 16;
  static const double _bottomPadding = 16;

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _entranceController.forward();
    loadPrayerData(true);
    _loadHadithData();
    loadProgress();
    _dzikirTicker = Timer.periodic(
      _dzikirCheckInterval,
      (_) => _updateDzikirPeriod(),
    );
  }

  void _updateDzikirPeriod() {
    final prayerModel = _prayerModel;
    final period = prayerModel == null
        ? null
        : DzikirPeriod.at(prayerModel, DateTime.now());
    if (period == _dzikirPeriod || !mounted) return;
    setState(() => _dzikirPeriod = period);
  }

  Future<void> _openDzikir(DzikirPeriod period) async {
    try {
      final categories = await DzikirProxy().getCategories();
      final category = categories
          .where((category) => category.id == period.categoryId)
          .firstOrNull;
      if (category == null || !mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DzikirDetailPage(category: category)),
      );
    } catch (e, st) {
      debugPrint('Opening dzikir failed: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.dzikirLoadFailed ?? ''),
        ),
      );
    }
  }

  /// Re-read when coming back to this tab, since prayers are marked on the
  /// prayers tab.
  Future<void> loadProgress() async {
    const prayers = PrayerLogProxy.trackedPrayers;
    final proxy = PrayerLogProxy();
    final today = DateTime.now();
    try {
      final done = await proxy.getDonePrayers(today);
      final streak = await proxy.getStreak(today, prayers);
      if (!mounted) return;
      setState(() {
        _progress = (
          completed: prayers.where(done.contains).length,
          total: prayers.length,
          streak: streak,
        );
      });
    } catch (e, st) {
      debugPrint('Loading prayer progress failed: $e\n$st');
    }
  }

  @override
  void dispose() {
    _dzikirTicker?.cancel();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> loadPrayerData(bool isInit) async {
    if (isInit) {
      /// Show cached times right away; the sync below refreshes them in the
      /// background. The skeleton stays only when there is no cache yet.
      await _readCachedPrayerData();
      if (mounted && _prayerModel != null) {
        setState(() => _isGettingPrayerData = false);
      }
    } else {
      setState(() => _isGettingPrayerData = true);
    }

    try {
      await PrayerSyncHelper().sync();
    } catch (e, st) {
      debugPrint('Prayer sync failed, using cache: $e\n$st');
    }

    await _loadCachedPrayerData();
  }

  Future<void> _loadCachedPrayerData() async {
    try {
      await _readCachedPrayerData();
    } finally {
      if (mounted) setState(() => _isGettingPrayerData = false);
    }

    final prayerModel = _prayerModel;
    if (prayerModel != null) await _updateWidgetAndNotifications(prayerModel);
  }

  Future<void> _readCachedPrayerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _location = prefs.getString(PrayerSyncHelper.keyLocationName);
      _isApproximate = prefs.getBool(PrayerSyncHelper.keyApproximate) ?? false;
      _prayerModel = await _prayerProxy.getTodayPrayer();
    } catch (e, st) {
      debugPrint('Reading cached prayer data failed: $e\n$st');
    }
    _updateDzikirPeriod();
  }

  Future<void> _updateWidgetAndNotifications(PrayerModel prayerModel) async {
    try {
      await Future.wait([
        WidgetHelper().updateWidgetLocation(),
        WidgetHelper().updateWidgetPrayer(prayerModel),
      ]);
      final notificationHelper = NotificationHelper();
      await notificationHelper.scheduleAllPrayerNotifications(prayerModel);
      await notificationHelper.scheduleReminderNotifications(prayerModel);
      await notificationHelper.scheduleMissedReminders(prayerModel);
    } catch (e, st) {
      debugPrint('Updating widget/notifications failed: $e\n$st');
    }
  }

  Future<void> _chooseCity() async {
    final cityName = await showDialog<String>(
      context: context,
      builder: (_) => const HomeCityPickerDialog(),
    );
    if (cityName == null || !mounted) return;

    setState(() => _isGettingPrayerData = true);
    final success = await PrayerSyncHelper().setManualLocation(cityName);
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.cityNotFound ?? ''),
        ),
      );
    }
    await _loadCachedPrayerData();
  }

  Future<void> _loadHadithData() async {
    HadithModel? hadithModel;
    try {
      hadithModel = await _hadithProxy.getDailyHadith();
    } catch (e, st) {
      debugPrint('Loading daily hadith failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _hadithModel = hadithModel;
      _isGettingHadithData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prayerModel = _prayerModel;
    final hadithModel = _hadithModel;

    final Widget prayerHeader;
    if (_isGettingPrayerData) {
      prayerHeader = const HomePrayerSkeleton();
    } else if (prayerModel != null) {
      prayerHeader = HomePrayerInfo(
        location: _location ?? '',
        prayerModel: prayerModel,
        onRefreshLocation: () => loadPrayerData(false),
        progress: _progress,
        onProgressTap: widget.onOpenPrayers,
      );
    } else {
      prayerHeader = HomePrayerError(
        onRetry: () => loadPrayerData(false),
        onChooseCity: _chooseCity,
      );
    }

    final showNotice =
        !_isGettingPrayerData && prayerModel != null && _isApproximate;
    final dzikirPeriod = _isGettingPrayerData ? null : _dzikirPeriod;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minFillHeight =
            MediaQuery.textScalerOf(context).scale(_minFillHeight) +
            (showNotice ? _noticeHeight : 0);

        /// Collapsed, the page is exactly one screen and the footer fills
        /// what the prayer card and menu leave, down to the bottom nav.
        final isHadithExpanded = _isHadithExpanded && dzikirPeriod == null;
        final fillsHeight =
            !isHadithExpanded && constraints.maxHeight >= minFillHeight;

        /// During a dzikir window the reminder takes the hadith's place;
        /// otherwise the hadith is optional and hidden if loading failed.
        final Widget? footer = switch ((dzikirPeriod, prayerModel)) {
          (final period?, final prayer?) => HomeDzikirReminder(
            period: period,
            endTime: period.endTime(prayer),
            onStart: () => _openDzikir(period),
          ),
          _ when _isGettingHadithData => const HomeHadithSkeleton(),
          _ when hadithModel != null => HomeHadithWidget(
            hadithModel: hadithModel,
            isExpanded: _isHadithExpanded,
            fillsHeight: fillsHeight,
            onToggleExpanded: () =>
                setState(() => _isHadithExpanded = !_isHadithExpanded),
          ),
          _ => null,
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: _bottomPadding),
          child: SizedBox(
            height: fillsHeight ? constraints.maxHeight - _bottomPadding : null,
            child: Column(
              children: [
                if (showNotice) ...[
                  StaggeredEntrance(
                    animation: _entranceController,
                    index: 0,
                    child: HomeApproximateNotice(
                      cityName: _location ?? '',
                      onChooseCity: _chooseCity,
                    ),
                  ),
                  const SizedBox(height: _sectionSpacing),
                ],
                Flexible(
                  flex: fillsHeight ? 1 : 0,
                  fit: FlexFit.tight,
                  child: StaggeredEntrance(
                    animation: _entranceController,
                    index: showNotice ? 1 : 0,
                    child: HomeOverviewCard(
                      header: prayerHeader,
                      footer: footer,
                      fillsHeight: fillsHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
