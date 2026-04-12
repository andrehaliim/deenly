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
    await _hadithProxy.fetchHadith();
    await _quranProxy.fetchSurahs();
    await NotificationHelper().requestPermission();
    bool? permission = await _locationProxy.requestPermission();
    if (permission == true) {
      await _locationProxy.getLocation().then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      });
    } else {
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
