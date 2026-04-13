import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_model.dart';

class WidgetHelper {
  Future<void> updateWidgetPrayer(PrayerModel prayerModel) async {
    await HomeWidget.saveWidgetData<String>(
      'fajr_time',
      prayerModel.fajr,
    );
    await HomeWidget.saveWidgetData<String>(
      'dhuhr_time',
      prayerModel.dhuhr,
    );
    await HomeWidget.saveWidgetData<String>(
      'asr_time',
      prayerModel.asr,
    );
    await HomeWidget.saveWidgetData<String>(
      'maghrib_time',
      prayerModel.maghrib,
    );
    await HomeWidget.saveWidgetData<String>(
      'isha_time',
      prayerModel.isha,
    );

    await HomeWidget.saveWidgetData<String>(
      'gregorian_date',
      prayerModel.date,
    );
    await HomeWidget.saveWidgetData<String>(
      'hijri_date',
      '${prayerModel.hijriDate} ${prayerModel.hijriMonth} ${prayerModel.hijriYear}',
    );

    await HomeWidget.updateWidget(name: 'DeenlyWidget');
  }

  Future<void> updateWidgetLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String location = prefs.getString('locationName') ?? '';
    await HomeWidget.saveWidgetData<String>(
      'location',
      location,
    );
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
