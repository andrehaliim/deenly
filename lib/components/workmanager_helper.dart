import 'package:deenly/components/notification_helper.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String dailyTaskName = "daily_midnight_notification_task";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    final notificationHelper = NotificationHelper();
    await notificationHelper.init();

    if (task == dailyTaskName) {
      final now = DateTime.now();
      final formatter = DateFormat('dd-MM-yyyy');
      final dateString = formatter.format(now);

      await notificationHelper.showDailyMidnightNotification(dateString);
    }

    return Future.value(true);
  });
}

class WorkmanagerHelper {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> scheduleDailyNotification() async {
    final now = DateTime.now();

    var scheduledTime = DateTime(now.year, now.month, now.day, 22, 50);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final initialDelay = scheduledTime.difference(now);

    await Workmanager().registerPeriodicTask(
      "1",
      dailyTaskName,
      frequency: const Duration(days: 1),
      initialDelay: initialDelay,
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }
}
