// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get nextPrayerTitle => 'Shalat Berikutnya';

  @override
  String get prayerTimes => 'Jadwal Shalat';

  @override
  String get fajr => 'Subuh';

  @override
  String get dhuhr => 'Dzuhur';

  @override
  String get asr => 'Ashar';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isya';

  @override
  String get menuHome => 'Beranda';

  @override
  String get menuQuran => 'Al-Qur\'an';

  @override
  String get menuMosque => 'Masjid';

  @override
  String get menuQibla => 'Kiblat';

  @override
  String get menuTasbih => 'Tasbih';

  @override
  String get menuSetting => 'Pengaturan';

  @override
  String get prayerProgress => 'Progress Shalat';

  @override
  String get completed => 'Selesai';

  @override
  String get hadithTitle => 'Hadis Harian';

  @override
  String get hadithNarrated => 'Diriwayatkan oleh: ';

  @override
  String get continueRead => 'Lanjutkan Membaca';

  @override
  String get continueAyah => 'Ayat Ke: ';

  @override
  String get ayah => 'Ayat';

  @override
  String get mosqueTryAgain => 'Coba Lagi';

  @override
  String get mosqueLoadAddress => 'Memuat Alamat...';

  @override
  String qiblaRotate(String degree, String direction) {
    return 'Putar ponsel $degree° ke $direction';
  }

  @override
  String get qiblaFacing => 'Kamu menghadap arah Kiblat!';

  @override
  String get right => 'kanan';

  @override
  String get left => 'kiri';

  @override
  String get errorRead => 'Error membaca kompas';

  @override
  String get errorNotSupport => 'Error: Perangkat ini tidak mendukung kompas';

  @override
  String get sessionTitle => 'Sesi Saat Ini';

  @override
  String get sessionSelect => 'Pilih Target';

  @override
  String get sessionReset => 'Reset Penghitung';

  @override
  String get sessionTap => 'Tap';

  @override
  String get settingLanguageTitle => 'Bahasa';

  @override
  String get settingAppearanceTitle => 'Tampilan';

  @override
  String get settingTheme => 'Mode Gelap';

  @override
  String get settingNotificationTitle => 'Notifikasi Shalat';

  @override
  String get settingTimeTitle => 'Penyesuaian Waktu';

  @override
  String get settingSaveButton => 'Simpan';

  @override
  String get settingBeforeTitle => 'Notifikasi sebelum adzan';

  @override
  String get settingBeforeValue => 'Nyalakan';

  @override
  String get searchSurahHint => 'Nama atau nomor surat...';

  @override
  String get surahList => 'Daftar Surat';

  @override
  String get filterByJuz => 'Filter : Juz';

  @override
  String get filterBySurah => 'Filter : Surat';

  @override
  String ayahCount(String number) {
    return 'Ayat $number';
  }

  @override
  String get noSurahFound => 'Surat tidak ditemukan';

  @override
  String get noJuzFound => 'Juz tidak ditemukan';

  @override
  String juzNumber(String number) {
    return 'Juz $number';
  }

  @override
  String ayahRange(String from, String to) {
    return 'Ayat $from - $to';
  }

  @override
  String get failedFetchSurahDetail => 'Gagal memuat detail surat';

  @override
  String get continueScrollNextSurah =>
      'Lanjutkan gulir ke bawah untuk berpindah ke surat berikutnya';
}
