import 'package:deenly/models/zakat_config_model.dart';

/// Values that change over time and are updated remotely, without a new
/// app release. The bundled copy in assets is the offline fallback.
class AppConfigModel {
  final String minAppVersion;
  final String updateUrl;
  final ZakatConfigModel zakat;

  /// Official first day of a Hijri month (e.g. from the sidang isbat),
  /// keyed by month index: `year * 12 + month - 1`.
  final Map<int, DateTime> hijriMonthStarts;

  const AppConfigModel({
    required this.minAppVersion,
    required this.updateUrl,
    required this.zakat,
    required this.hijriMonthStarts,
  });

  /// [json]'s `hijri_month_starts` maps "1448-09" to "2027-02-08".
  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    final rawStarts = json['hijri_month_starts'] as Map<String, dynamic>?;
    final starts = <int, DateTime>{};
    rawStarts?.forEach((key, value) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      if (month < 1 || month > 12) {
        throw FormatException('Invalid Hijri month: $key');
      }

      /// Only the calendar date counts: a time or UTC offset would move the
      /// start to another local day.
      final date = DateTime.parse((value as String).split('T').first);
      starts[year * 12 + month - 1] = DateTime(date.year, date.month, date.day);
    });

    return AppConfigModel(
      minAppVersion: json['min_app_version'] as String,
      updateUrl: json['update_url'] as String,
      zakat: ZakatConfigModel.fromJson(json['zakat'] as Map<String, dynamic>),
      hijriMonthStarts: starts,
    );
  }

  bool requiresUpdate(String appVersion) {
    final current = _versionParts(appVersion);
    final minimum = _versionParts(minAppVersion);
    final length = current.length > minimum.length
        ? current.length
        : minimum.length;
    for (var i = 0; i < length; i++) {
      final a = i < current.length ? current[i] : 0;
      final b = i < minimum.length ? minimum[i] : 0;
      if (a != b) return a < b;
    }
    return false;
  }

  /// "1.2.0+5" becomes [1, 2, 0]; the build number is ignored.
  static List<int> _versionParts(String version) {
    return version
        .split('+')
        .first
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}
