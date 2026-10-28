import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/hijri_date_model.dart';

class HijriFormat {
  static String monthName(AppLocalizations? l10n, int month) {
    if (l10n == null) return '$month';
    return switch (month) {
      1 => l10n.hijriMuharram,
      2 => l10n.hijriSafar,
      3 => l10n.hijriRabiulAwal,
      4 => l10n.hijriRabiulAkhir,
      5 => l10n.hijriJumadilAwal,
      6 => l10n.hijriJumadilAkhir,
      7 => l10n.hijriRajab,
      8 => l10n.hijriShaban,
      9 => l10n.hijriRamadan,
      10 => l10n.hijriShawwal,
      11 => l10n.hijriDhulQadah,
      _ => l10n.hijriDhulHijjah,
    };
  }

  /// e.g. "16 Jumadil Awal 1448 H".
  static String full(AppLocalizations? l10n, HijriDateModel date) {
    return l10n?.calendarHijriDate(
          date.day,
          monthName(l10n, date.month),
          date.year,
        ) ??
        '';
  }

  /// e.g. "Jumadil Awal 1448 H".
  static String monthYear(AppLocalizations? l10n, int year, int month) {
    return l10n?.calendarHijriMonthYear(monthName(l10n, month), year) ?? '';
  }
}
