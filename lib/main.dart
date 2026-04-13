import 'package:deenly/components/app_theme.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:deenly/components/workmanager_helper.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:deenly/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';

const String dailyTaskName = "daily_midnight_notification_task";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('🔵 Workmanager START');
    debugPrint('📌 Task: $task');
    debugPrint('📦 InputData: $inputData');

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      final notificationHelper = NotificationHelper();
      await notificationHelper.init();

      if (task == dailyTaskName) {
        final now = DateTime.now();
        debugPrint('⏰ Current time: $now');

        final formatter = DateFormat('dd-MM-yyyy');
        final dateString = formatter.format(now);

        debugPrint('📅 Formatted date: $dateString');

        await notificationHelper.showDailyMidnightNotification(dateString);

        debugPrint('✅ Notification triggered successfully');
      } else {
        debugPrint('⚠️ Unknown task received');
      }

      debugPrint('🟢 Workmanager END');
      return Future.value(true);
    } catch (e, stack) {
      debugPrint('🔴 ERROR in Workmanager');
      debugPrint(e.toString());
      debugPrint(stack.toString());
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
