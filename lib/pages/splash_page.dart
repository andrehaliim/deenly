import 'package:deenly/components/app_config_provider.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/fade_page_route.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/prayer_sync_helper.dart';
import 'package:deenly/pages/main_page.dart';
import 'package:deenly/pages/permission/permission_page.dart';
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

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // Intro and exit together set the splash length; slow loading can only
  // delay the exit, never cut either animation short.
  static const _introDuration = Duration(milliseconds: 1750);
  static const _exitDuration = Duration(milliseconds: 900);

  final HadithProxy _hadithProxy = HadithProxy();
  final LocationProxy _locationProxy = LocationProxy();

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _introDuration,
  );

  /// Played once loading is done: the title and tagline grow slightly while
  /// fading into the background.
  late final AnimationController _exitController = AnimationController(
    vsync: this,
    duration: _exitDuration,
  );

  late final Animation<double> _contentOpacity = _exitController.drive(
    Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: Curves.easeIn)),
  );

  late final Animation<double> _contentScale = _exitController.drive(
    Tween<double>(
      begin: 1,
      end: 1.12,
    ).chain(CurveTween(curve: Curves.easeInCubic)),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _start();
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    // Keep the splash up until the intro animation has finished.
    final introDone = Future<void>.delayed(_introDuration);
    final nextPage = await _loadData();
    await introDone;

    if (!mounted) return;
    await _exitController.forward();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      FadePageRoute(builder: (context) => nextPage),
    );
  }

  Future<Widget> _loadData() async {
    debugPrint('🔄 [0/8] Starting _loadData...');

    // Fetched alongside the local steps, so it rarely adds any wait.
    final appConfig = context.read<AppConfigProvider>();
    final drawerProvider = context.read<DrawerProvider>();
    final configLoaded = appConfig.load();

    await _hadithProxy.load();
    debugPrint('✅ [1/8] Hadith loaded');

    await DatabaseHelper.instance.seedSurahIfNeeded();
    debugPrint('✅ [2/8] Surah seeded');

    await DatabaseHelper.instance.seedJuzIfNeeded();
    debugPrint('✅ [3/8] Juz seeded');

    await DatabaseHelper.instance.seedDoaIfNeeded();
    debugPrint('✅ [4/8] Doa seeded');

    await DatabaseHelper.instance.seedAsmaulHusnaIfNeeded();
    debugPrint('✅ [5/8] Asmaul Husna seeded');

    await DatabaseHelper.instance.seedDzikirIfNeeded();
    debugPrint('✅ [6/8] Dzikir seeded');

    await configLoaded;
    debugPrint('✅ [7/8] App config loaded');

    final updateUrl = appConfig.config?.updateUrl;
    if (appConfig.requiresUpdate && updateUrl != null) {
      return UpdateRequiredPage(updateUrl: updateUrl);
    }

    final nextPage = await _resolveNextPage(drawerProvider);
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
        // Same background as the home screen, so the fade into it is seamless.
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _contentOpacity,
                child: ScaleTransition(
                  scale: _contentScale,
                  child: SplashTextWidget(animation: _controller),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
