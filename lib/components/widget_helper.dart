import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_model.dart';

class WidgetHelper {
  Future<void> updateWidgetPrayer(PrayerModel prayerModel) async {
    final data = {
      'fajr_time': prayerModel.fajr,
      'dhuhr_time': prayerModel.dhuhr,
      'asr_time': prayerModel.asr,
      'maghrib_time': prayerModel.maghrib,
      'isha_time': prayerModel.isha,
      'gregorian_date': DateFormat('dd MMM yyyy').format(
        DateFormat('dd-MM-yyyy').parse(prayerModel.date),
      ),
      'hijri_date':
          '${prayerModel.hijriDate} '
          '${prayerModel.hijriMonth} '
          '${prayerModel.hijriYear}',
    };

    for (final entry in data.entries) {
      await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
    }

    await HomeWidget.updateWidget(name: 'DeenlyWidget');
  }

  Future<void> updateWidgetLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String location = prefs.getString('locationName') ?? '';
    await HomeWidget.saveWidgetData<String>('location', location);
    await HomeWidget.updateWidget(name: 'DeenlyWidget');
  }

  Future<void> updateWidgetNotification(
    String prayerName,
    bool isEnabled,
  ) async {
    await HomeWidget.saveWidgetData<bool>(
      '${prayerName}_notification',
      isEnabled,
    );
    await HomeWidget.updateWidget(name: 'DeenlyWidget');
  }
}
