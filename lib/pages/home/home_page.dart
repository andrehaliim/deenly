import 'dart:convert';

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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocationProxy _locationProxy = LocationProxy();
  final PrayerProxy _prayerProxy = PrayerProxy();
  bool _isGettingPrayerData = false;
  String _location = '';
  PrayerModel? _prayerModel;
  HadithModel? _hadithModel;

  @override
  void initState() {
    super.initState();
    _loadData(true);
  }

  Future<void> _loadData(bool isInit) async {
    setState(() {
      _isGettingPrayerData = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final String prefLocation = prefs.getString('location') ?? '';

    Position position;
    if (isInit && prefLocation.isEmpty) {
      position = _locationProxy.getDefaultPosition();
    } else {
      position = await _locationProxy.requestLocation();
    }
    final String location = await _locationProxy.getAddressFromLatLng(position);

    final PrayerModel prayerModel = await _prayerProxy.getDailyPrayer(
      position.latitude,
      position.longitude,
    );
    if (location != prefLocation) {
      prefs.setString('location', location);
    }
      prefs.setString('prayer_data', json.encode(prayerModel.toJson()));

    final HadithModel hadithModel = await HadithProxy().getDailyHadith();

    setState(() {
      _isGettingPrayerData = false;
      _prayerModel = prayerModel;
      _location = location;
      _hadithModel = hadithModel;
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
                  location: _location,
                  prayerModel: _prayerModel!,
                  onRefreshLocation: () => _loadData(false),
                ),

          const SizedBox(height: 10),

          HomePrayerProgress(),

          const SizedBox(height: 10),

          _isGettingPrayerData
              ? HomeHadithSkeleton()
              : HomeHadithWidget(hadithModel: _hadithModel!),
        ],
      ),
    );
  }
}
