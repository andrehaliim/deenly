import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/prayer_sync_helper.dart';
import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/hadith_model.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/home/home_approximate_notice.dart';
import 'package:deenly/pages/home/home_city_picker_dialog.dart';
import 'package:deenly/pages/home/home_hadith_skeleton.dart';
import 'package:deenly/pages/home/home_hadith_widget.dart';
import 'package:deenly/pages/home/home_menu_grid.dart';
import 'package:deenly/pages/home/home_prayer_error.dart';
import 'package:deenly/pages/home/home_prayer_info.dart';
import 'package:deenly/pages/home/home_prayer_skeleton.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
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

    final Widget prayerSection;
    if (_isGettingPrayerData) {
      prayerSection = const HomePrayerSkeleton();
    } else if (prayerModel != null) {
      prayerSection = Column(
        children: [
          HomePrayerInfo(
            location: _location ?? '',
            prayerModel: prayerModel,
            onRefreshLocation: () => loadPrayerData(false),
            progress: _progress,
            onProgressTap: widget.onOpenPrayers,
          ),
          if (_isApproximate)
            HomeApproximateNotice(
              cityName: _location ?? '',
              onChooseCity: _chooseCity,
            ),
        ],
      );
    } else {
      prayerSection = HomePrayerError(
        onRetry: () => loadPrayerData(false),
        onChooseCity: _chooseCity,
      );
    }

    /// The hadith card is optional: hide it if loading failed.
    final Widget? hadithSection = _isGettingHadithData
        ? const HomeHadithSkeleton()
        : hadithModel != null
        ? HomeHadithWidget(hadithModel: hadithModel)
        : null;

    final sections = [prayerSection, const HomeMenuGrid(), ?hadithSection];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            StaggeredEntrance(
              animation: _entranceController,
              index: i,

              /// The hadith card sizes itself from its on-screen position,
              /// so it only fades in to keep that position stable.
              slideFrom: sections[i] is HomeHadithWidget
                  ? Offset.zero
                  : const Offset(0, 0.25),
              child: sections[i],
            ),
          ],
        ],
      ),
    );
  }
}
