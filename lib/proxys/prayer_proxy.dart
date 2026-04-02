import 'dart:convert';
import 'package:deenly/models/prayer_model.dart';
import 'package:http/http.dart' as http;

class PrayerProxy {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  Future<PrayerModel> getTimings(double lat, double lon) async {
    final now = DateTime.now();
    final formattedDate = '${now.day}-${now.month}-${now.year}';
    //final tune = '&tune=0%2C2%2C0%2C3%2C1%2C6%2C0%2C2%2C0';
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/timings/$formattedDate?latitude=$lat&longitude=$lon&method=20&timezonestring=Asia%2FJakarta',
      ),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      return PrayerModel.fromJson(decodedResponse['data']);
    } else {
      throw Exception('Failed to load prayer timings');
    }
  }

  Map<String, String> getNextPrayer(Map<String, dynamic> timings) {
    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    String nextPrayer = 'Fajr';
    String nextTime = timings['Fajr'];

    for (var prayer in prayers) {
      final prayerTimeStr = timings[prayer] as String;
      final parts = prayerTimeStr.split(':');
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (prayerTime.isAfter(now)) {
        nextPrayer = prayer;
        nextTime = prayerTimeStr;
        break;
      }
    }
    return {
      'nextPrayer': nextPrayer,
      'nextTime': nextTime,
    };
  }
}
