import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_model.dart';
import '../proxys/prayer_proxy.dart';

class WidgetHelper {
  /// The native widget switches to this copy after midnight, before the
  /// app or the daily task has refreshed the data.
  static const String _tomorrowPrefix = 'tomorrow_';

  Future<void> updateWidgetPrayer(PrayerModel prayerModel) async {
    final today = DateFormat('dd-MM-yyyy').parse(prayerModel.date);
    final tomorrow = await PrayerProxy().getPrayerForDate(
      DateTime(today.year, today.month, today.day + 1),
    );

    final data = {
      ..._prayerData(prayerModel),
      if (tomorrow != null)
        for (final entry in _prayerData(tomorrow).entries)
          '$_tomorrowPrefix${entry.key}': entry.value,
      if (tomorrow == null) '${_tomorrowPrefix}date': '',
    };

    for (final entry in data.entries) {
      await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
    }

    await HomeWidget.updateWidget(name: 'DeenlyWidget');
  }

  Map<String, String> _prayerData(PrayerModel prayerModel) => {
    'date': prayerModel.date,
    'fajr_time': prayerModel.fajr,
    'dhuhr_time': prayerModel.dhuhr,
    'asr_time': prayerModel.asr,
    'maghrib_time': prayerModel.maghrib,
    'isha_time': prayerModel.isha,
    'gregorian_date': DateFormat(
      'dd MMM yyyy',
    ).format(DateFormat('dd-MM-yyyy').parse(prayerModel.date)),
    'hijri_date':
        '${prayerModel.hijriDate} '
        '${prayerModel.hijriMonth} '
        '${prayerModel.hijriYear}',
  };

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
