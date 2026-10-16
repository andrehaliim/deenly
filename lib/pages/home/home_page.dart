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
import 'package:deenly/pages/home/home_prayer_error.dart';
import 'package:deenly/pages/home/home_prayer_info.dart';
import 'package:deenly/pages/home/home_prayer_progress.dart';
import 'package:deenly/pages/home/home_prayer_skeleton.dart';
import 'package:deenly/proxys/hadith_proxy.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final PrayerProxy _prayerProxy = PrayerProxy();
  final HadithProxy _hadithProxy = HadithProxy();
  bool _isGettingPrayerData = true;
  bool _isGettingHadithData = true;
  String? _location;
  bool _isApproximate = false;
  PrayerModel? _prayerModel;
  HadithModel? _hadithModel;

  @override
  void initState() {
    super.initState();
    loadPrayerData(true);
    _loadHadithData();
  }

  Future<void> loadPrayerData(bool isInit) async {
    setState(() => _isGettingPrayerData = true);

    try {
      await PrayerSyncHelper().sync();
    } catch (e, st) {
      debugPrint('Prayer sync failed, using cache: $e\n$st');
    }

    await _loadCachedPrayerData();
  }

  Future<void> _loadCachedPrayerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _location = prefs.getString(PrayerSyncHelper.keyLocationName);
      _isApproximate = prefs.getBool(PrayerSyncHelper.keyApproximate) ?? false;

      final prayerModel = await _prayerProxy.getTodayPrayer();
      _prayerModel = prayerModel;

      if (prayerModel != null) {
        await Future.wait([
          WidgetHelper().updateWidgetLocation(),
          WidgetHelper().updateWidgetPrayer(prayerModel),
        ]);
        final notificationHelper = NotificationHelper();
        await notificationHelper.scheduleAllPrayerNotifications(prayerModel);
        await notificationHelper.scheduleReminderNotifications(prayerModel);
      }
    } catch (e, st) {
      debugPrint('loadPrayerData failed: $e\n$st');
    } finally {
      if (mounted) setState(() => _isGettingPrayerData = false);
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              AppLocalizations.of(context)!.assalamuAlaikum,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          if (_isGettingPrayerData)
            const HomePrayerSkeleton()
          else if (prayerModel != null) ...[
            HomePrayerInfo(
              location: _location ?? '',
              prayerModel: prayerModel,
              onRefreshLocation: () => loadPrayerData(false),
            ),
            if (_isApproximate)
              HomeApproximateNotice(
                cityName: _location ?? '',
                onChooseCity: _chooseCity,
              ),
          ] else
            HomePrayerError(
              onRetry: () => loadPrayerData(false),
              onChooseCity: _chooseCity,
            ),

          const SizedBox(height: 10),

          HomePrayerProgress(),

          const SizedBox(height: 10),

          // The hadith card is optional: hide it if loading failed.
          if (_isGettingHadithData)
            HomeHadithSkeleton()
          else if (hadithModel != null)
            HomeHadithWidget(hadithModel: hadithModel),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
