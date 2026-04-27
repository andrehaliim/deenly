import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/models/hadith_model.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/home/home_hadith_skeleton.dart';
import 'package:deenly/pages/home/home_hadith_widget.dart';
import 'package:deenly/pages/home/home_prayer_info.dart';
import 'package:deenly/pages/home/home_prayer_progress.dart';
import 'package:deenly/pages/home/home_prayer_skeleton.dart';
import 'package:deenly/proxys/hadith_proxy.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  PrayerModel? _prayerModel;
  HadithModel? _hadithModel;

  @override
  void initState() {
    super.initState();
    loadPrayerData(true);
    _loadHadithData();
  }

  Future<void> loadPrayerData(bool isInit) async {
    setState(() {
      _isGettingPrayerData = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final locationName = prefs.getString('locationName') ?? '';
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    Position position = await Geolocator.getCurrentPosition();

    bool? locationChanged = await LocationProxy().isLocationChanged(position);


    if (locationChanged == true || isFirstLaunch) {
      await _prayerProxy.clearPrayer();
      await _prayerProxy.fetchMonthlyPrayer(
        position.latitude,
        position.longitude,
      );

      prefs.setDouble('lat', position.latitude);
      prefs.setDouble('long', position.longitude);
      _location = await LocationProxy().getLocationName(position);
      prefs.setString('locationName', _location!);
      prefs.setBool('isFirstLaunch', false);
    } else {
      _location = locationName;
    }

    _prayerModel = await _prayerProxy.getTodayPrayer();

    WidgetHelper().updateWidgetPrayer(_prayerModel!);
    WidgetHelper().updateWidgetLocation();

    await NotificationHelper().scheduleAllPrayerNotifications(_prayerModel!);

    setState(() {
      _isGettingPrayerData = false;
    });
  }

  Future<void> _loadHadithData() async {
    _hadithModel = await _hadithProxy.getDailyHadith();

    setState(() {
      _isGettingHadithData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'Assalamu Alaikum,',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          _isGettingPrayerData
              ? HomePrayerSkeleton()
              : HomePrayerInfo(
                  location: _location!,
                  prayerModel: _prayerModel!,
                  onRefreshLocation: () => loadPrayerData(false),
                ),

          const SizedBox(height: 10),

          HomePrayerProgress(),

          const SizedBox(height: 10),

          _isGettingHadithData
              ? HomeHadithSkeleton()
              : HomeHadithWidget(hadithModel: _hadithModel!),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
