import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/fade_page_route.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/pages/main_page.dart';
import 'package:deenly/pages/no_location_page.dart';
import 'package:deenly/pages/splash/splash_loader_widget.dart';
import 'package:deenly/pages/splash/splash_logo_widget.dart';
import 'package:deenly/pages/splash/splash_text_widget.dart';
import 'package:deenly/proxys/hadith_proxy.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _introDuration = Duration(milliseconds: 1600);
  static const _totalSteps = 5;

  final HadithProxy _hadithProxy = HadithProxy();
  final LocationProxy _locationProxy = LocationProxy();

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _introDuration,
  );

  int _completedSteps = 0;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    // Keep the splash up until the intro animation has finished.
    final introDone = Future<void>.delayed(_introDuration);
    final permission = await _loadData();
    await introDone;

    // Let the progress bar finish filling up before leaving.
    await Future<void>.delayed(SplashLoaderWidget.fillDuration);

    if (!mounted) return;

    if (permission != true) {
      debugPrint('🚫 Location permission denied, redirecting...');
    }

    Navigator.pushReplacement(
      context,
      FadePageRoute(
        builder: (context) =>
            permission == true ? const MainPage() : const NoLocationPage(),
      ),
    );
  }

  void _completeStep() {
    if (!mounted) return;
    setState(() => _completedSteps++);
  }

  Future<bool?> _loadData() async {
    debugPrint('🔄 [1/5] Starting _loadData...');

    await _hadithProxy.load();
    _completeStep();
    debugPrint('✅ [2/5] Hadith loaded');

    await NotificationHelper().requestPermission();
    _completeStep();
    debugPrint('✅ [3/5] Notification permission done');

    bool? permission = await _locationProxy.requestPermission();
    _completeStep();
    debugPrint('✅ [4/5] Location permission result: $permission');

    await DatabaseHelper.instance.seedSurahIfNeeded();
    _completeStep();
    debugPrint('✅ [5/5] Surah seeded');

    await DatabaseHelper.instance.seedJuzIfNeeded();
    _completeStep();
    debugPrint('✅ [6/6] Juz seeded');

    return permission;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SplashLogoWidget(animation: _controller),
                  const SizedBox(height: 32),
                  SplashTextWidget(animation: _controller),
                  const SizedBox(height: 40),
                  SplashLoaderWidget(
                    animation: _controller,
                    progress: _completedSteps / _totalSteps,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
