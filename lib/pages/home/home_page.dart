import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/home/home_daily_hadith.dart';
import 'package:deenly/pages/home/home_prayer_info.dart';
import 'package:deenly/pages/home/home_prayer_progress.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocationProxy _locationProxy = LocationProxy();
  final PrayerProxy _prayerProxy = PrayerProxy();
  Future<Map<String, dynamic>>? _pageData;

  @override
  void initState() {
    super.initState();
    _pageData = _loadPageData();
  }

  Future<Map<String, dynamic>> _loadPageData() async {
    final Position position = await _locationProxy.requestLocation();
    final String location = await _locationProxy.getAddressFromLatLng(position);
    final PrayerModel prayerModel = await _prayerProxy.getDailyPrayer(
      position.latitude,
      position.longitude,
    );

    return {'location': location, 'prayerModel': prayerModel};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _pageData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;

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

              HomePrayerInfo(
                location: data['location'],
                prayerModel: data['prayerModel'],
              ),

              const SizedBox(height: 10),

              HomePrayerProgress(),

              const SizedBox(height: 10),

              HomeDailyHadith(),
            ],
          ),
        );
      },
    );
  }
}
