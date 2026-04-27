import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/pages/main_page.dart';
import 'package:deenly/pages/no_location_page.dart';
import 'package:deenly/proxys/hadith_proxy.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:deenly/proxys/quran_proxy.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final HadithProxy _hadithProxy = HadithProxy();
  final QuranProxy _quranProxy = QuranProxy();
  final LocationProxy _locationProxy = LocationProxy();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    debugPrint('🔄 [1/5] Starting _loadData...');

    await _hadithProxy.load();
    debugPrint('✅ [2/5] Hadith loaded');

    await _quranProxy.fetchSurahs();
    debugPrint('✅ [3/5] Surahs fetched');

    await NotificationHelper().requestPermission();
    debugPrint('✅ [4/5] Notification permission done');

    bool? permission = await _locationProxy.requestPermission();
    debugPrint('✅ [5/5] Location permission result: $permission');

    if (permission == true) {
      debugPrint('📍 Getting location...');
      await _locationProxy.getLocation().then((value) {
        debugPrint('✅ Location received');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      });
    } else {
      print('🚫 Location permission denied, redirecting...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoLocationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafaf7),
      body: Center(child: Image.asset('assets/images/splash.png')),
    );
  }
}
