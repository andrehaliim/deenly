import 'dart:ui';

import 'package:deenly/components/app_theme.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/surah_provider.dart';
import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/components/workmanager_helper.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/splash_page.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

const String dailyTaskName = "daily_refresh_prayer";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();

      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      final notificationHelper = NotificationHelper();

      await notificationHelper.init();

      if (task == dailyTaskName) {
        final PrayerModel? prayerModel = await PrayerProxy().getTodayPrayer();
        if (prayerModel != null) {
          await notificationHelper.scheduleAllPrayerNotifications(prayerModel);
          await notificationHelper.scheduleReminderNotifications(prayerModel);
          await WidgetHelper().updateWidgetPrayer(prayerModel);
          await WorkmanagerHelper.scheduleNextPrayerUpdate();
        }
        await WorkmanagerHelper.scheduleDailyNotification();
      } else if (task == 'nextPrayerTaskUpdate') {
        final nextPrayerName = inputData?['nextPrayerName'] as String?;
        if (nextPrayerName != null) {
          await WidgetHelper().updateWidgetNextPrayer(nextPrayerName);
        }
      }
      return true;
    } catch (e) {
      try {
        final n = NotificationHelper();
        await n.init();
        await n.showNotification(
          id: 99,
          title: '[$task] Failed',
          body: e.toString(),
        );
      } catch (_) {}
      return false;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  // Init database
  await DatabaseHelper.instance.database;

  // Init notification
  await NotificationHelper().init();

  // Init and schedule background tasks
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().cancelAll();
  await WorkmanagerHelper.scheduleDailyNotification();
  await WorkmanagerHelper.scheduleNextPrayerUpdate();
  
  // Load preferences
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDark)),
        ChangeNotifierProvider(create: (_) => DrawerProvider(prefs)),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProxyProvider<LocaleProvider, SurahProvider>(
          create: (_) => SurahProvider(),
          update: (_, localeProvider, surahProvider) {
            surahProvider!.updateLanguage(localeProvider.locale?.languageCode);
            return surahProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: localeProvider.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('id')],
          home: SplashPage(),
        );
      },
    );
  }
}
