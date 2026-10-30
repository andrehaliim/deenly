import 'package:deenly/components/app_config_provider.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/fade_page_route.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/prayer_sync_helper.dart';
import 'package:deenly/pages/main_page.dart';
import 'package:deenly/pages/permission/permission_page.dart';
import 'package:deenly/pages/splash/splash_loader_widget.dart';
import 'package:deenly/pages/splash/splash_logo_widget.dart';
import 'package:deenly/pages/splash/splash_text_widget.dart';
import 'package:deenly/pages/update/update_required_page.dart';
import 'package:deenly/proxys/hadith_proxy.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _introDuration = Duration(milliseconds: 1600);
  static const _totalSteps = 8;

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
    final nextPage = await _loadData();
    await introDone;

    // Let the progress bar finish filling up before leaving.
    await Future<void>.delayed(SplashLoaderWidget.fillDuration);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      FadePageRoute(builder: (context) => nextPage),
    );
  }

  void _completeStep() {
    if (!mounted) return;
    setState(() => _completedSteps++);
  }

  Future<Widget> _loadData() async {
    debugPrint('🔄 [0/8] Starting _loadData...');

    // Fetched alongside the local steps, so it rarely adds any wait.
    final appConfig = context.read<AppConfigProvider>();
    final drawerProvider = context.read<DrawerProvider>();
    final configLoaded = appConfig.load();

    await _hadithProxy.load();
    _completeStep();
    debugPrint('✅ [1/8] Hadith loaded');

    await DatabaseHelper.instance.seedSurahIfNeeded();
    _completeStep();
    debugPrint('✅ [2/8] Surah seeded');

    await DatabaseHelper.instance.seedJuzIfNeeded();
    _completeStep();
    debugPrint('✅ [3/8] Juz seeded');

    await DatabaseHelper.instance.seedDoaIfNeeded();
    _completeStep();
    debugPrint('✅ [4/8] Doa seeded');

    await DatabaseHelper.instance.seedAsmaulHusnaIfNeeded();
    _completeStep();
    debugPrint('✅ [5/8] Asmaul Husna seeded');

    await DatabaseHelper.instance.seedDzikirIfNeeded();
    _completeStep();
    debugPrint('✅ [6/8] Dzikir seeded');

    await configLoaded;
    _completeStep();
    debugPrint('✅ [7/8] App config loaded');

    final updateUrl = appConfig.config?.updateUrl;
    if (appConfig.requiresUpdate && updateUrl != null) {
      _completeStep();
      return UpdateRequiredPage(updateUrl: updateUrl);
    }

    final nextPage = await _resolveNextPage(drawerProvider);
    _completeStep();
    debugPrint('✅ [8/8] Permission status checked');

    return nextPage;
  }

  /// Only checks the permission status; the system dialogs are shown on
  /// [PermissionPage] together with an explanation.
  Future<Widget> _resolveNextPage(DrawerProvider drawerProvider) async {
    final hasLocation =
        await _locationProxy.hasPermission() ||
        await PrayerSyncHelper().hasSavedLocation();
    final notificationHelper = NotificationHelper();
    if (await notificationHelper.shouldEnableByDefault()) {
      await drawerProvider.enableAllNotifications();
      await notificationHelper.markPermissionAsked();
    }
    final askNotification = await notificationHelper.shouldAskPermission();

    if (hasLocation && !askNotification) return const MainPage();

    return PermissionPage(
      askLocation: !hasLocation,
      askNotification: askNotification,
    );
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
