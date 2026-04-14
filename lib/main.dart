import 'package:deenly/components/app_theme.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/components/workmanager_helper.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/pages/splash_page.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

const String dailyTaskName = "daily_refresh_prayer";
const String updateNextPrayerTaskName = "update_next_prayer_task";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notificationHelper = NotificationHelper();

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      await notificationHelper.init();

      if (task == dailyTaskName) {
        final now = DateTime.now();

        if (now.day == 1) {
          final prefs = await SharedPreferences.getInstance();
          final lat = prefs.getDouble('latitude');
          final lon = prefs.getDouble('longitude');

          if (lat != null && lon != null) {
            await PrayerProxy().fetchMonthlyPrayer(lat, lon);
          }
        }

        final PrayerModel prayerModel = await PrayerProxy().getTodayPrayer();
        await notificationHelper.scheduleAllPrayerNotifications(prayerModel);
        await WidgetHelper().updateWidgetPrayer(prayerModel);
        Map<String, String> nextPrayer = PrayerProxy().getNextPrayer(prayerModel.toJson());
        await WidgetHelper().updateWidgetNextPrayer(nextPrayer['nextPrayer']!);

      } else if (task == updateNextPrayerTaskName) {
        final prayerName = inputData?['next_prayer_name'];
        await WidgetHelper().updateWidgetNextPrayer(prayerName);
      }

      return Future.value(true);
    } catch (e) {
      await notificationHelper.showNotification(
        id: 99,
        title: '[$task] Background Task Failed',
        body: e.toString(),
      );
      return Future.value(false);
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

  // Load preferences
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDark)),
        ChangeNotifierProvider(create: (_) => DrawerProvider(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: SplashPage(),
        );
      },
    );
  }
}
