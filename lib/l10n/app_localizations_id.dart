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
  String get menuPrayers => 'Shalat';

  @override
  String get menuDoa => 'Doa';

  @override
  String get menuAsmaulHusna => 'Asmaul Husna';

  @override
  String get menuDzikir => 'Dzikir';

  @override
  String get menuCalendar => 'Kalender';

  @override
  String get menuZakat => 'Zakat';

  @override
  String get prayerProgress => 'Progress Shalat';

  @override
  String get completed => 'Selesai';

  @override
  String get hadithTitle => 'Hadis Harian';

  @override
  String get hadithNarrated => 'Diriwayatkan oleh: ';

  @override
  String get showMore => 'Selengkapnya';

  @override
  String get showLess => 'Lebih sedikit';

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
  String get settingAboutTitle => 'Tentang';

  @override
  String get settingPrivacyPolicy => 'Kebijakan Privasi';

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

  @override
  String get prayerLoadFailed =>
      'Gagal memuat jadwal sholat. Periksa koneksi internet dan lokasi Anda, lalu coba lagi.';

  @override
  String get retry => 'Coba Lagi';

  @override
  String approximateLocationNotice(String city) {
    return 'Waktu perkiraan berdasarkan zona waktu ($city). Nyalakan GPS untuk waktu yang akurat.';
  }

  @override
  String get chooseCity => 'Pilih kota';

  @override
  String get cityNameHint => 'Nama kota';

  @override
  String get cityNotFound =>
      'Kota tidak ditemukan atau tidak ada koneksi internet.';

  @override
  String get useCity => 'Gunakan';

  @override
  String get cancel => 'Batal';

  @override
  String get locationPermissionDenied => 'Izin lokasi ditolak';

  @override
  String get locationPermissionDeniedForever =>
      'Izin lokasi ditolak permanen, silakan aktifkan di pengaturan';

  @override
  String get assalamuAlaikum => 'Assalamu\'alaikum,';

  @override
  String get noMosqueFound => 'Tidak ada masjid dalam radius 2 km.';

  @override
  String get couldNotOpenMaps => 'Tidak dapat membuka Google Maps.';

  @override
  String get couldNotOpenLink => 'Tidak dapat membuka tautan.';

  @override
  String get notificationScheduleFailed => 'Gagal menjadwalkan notifikasi';

  @override
  String get reminderEnableFailed => 'Tidak dapat mengaktifkan pengingat';

  @override
  String get adjustmentSaveFailed => 'Gagal menyimpan penyesuaian waktu sholat';

  @override
  String get notificationAdhanTitle => 'Pengingat Adzan';

  @override
  String notificationAdhanBody(String prayer) {
    return 'Sudah masuk waktu shalat $prayer';
  }

  @override
  String get notificationReminderTitle => 'Pengingat Shalat';

  @override
  String notificationReminderBody(String prayer) {
    return '10 menit lagi menuju waktu shalat $prayer';
  }

  @override
  String get qiblaNoLocation =>
      'Lokasi belum tersedia. Aktifkan GPS atau pilih kota di halaman Beranda.';

  @override
  String get mosqueLocationUnavailable =>
      'Tidak dapat mengambil lokasimu. Pastikan GPS aktif dan izin lokasi sudah diberikan.';

  @override
  String get mosqueLoadFailed => 'Gagal memuat masjid terdekat.';

  @override
  String get asmaulHusnaLoadFailed => 'Gagal memuat Asmaul Husna.';

  @override
  String get appTitle => 'Deenly';

  @override
  String get splashTagline => 'Teman ibadah Muslim modern';

  @override
  String get permissionLocationTitle =>
      'Aktifkan lokasi untuk jadwal sholat yang akurat';

  @override
  String get permissionLocationSubtitle =>
      'Deenly memakai lokasi Anda untuk menghitung jadwal sholat, menentukan arah kiblat, dan menampilkan masjid terdekat.';

  @override
  String get permissionReasonPrayerTitle => 'Jadwal sholat akurat';

  @override
  String get permissionReasonPrayerBody =>
      'Waktu Subuh hingga Isya dihitung sesuai tempat Anda berada.';

  @override
  String get permissionReasonQiblaTitle => 'Arah kiblat';

  @override
  String get permissionReasonQiblaBody =>
      'Kompas yang menunjuk ke arah Ka\'bah dari posisi Anda.';

  @override
  String get permissionReasonMosqueTitle => 'Masjid terdekat';

  @override
  String get permissionReasonMosqueBody =>
      'Masjid dalam radius 2 km beserta jaraknya dari Anda.';

  @override
  String get permissionLocationPrivacy =>
      'Lokasi Anda hanya dipakai untuk jadwal sholat, arah kiblat, dan masjid terdekat.';

  @override
  String get permissionAllowLocation => 'Izinkan lokasi';

  @override
  String get permissionChooseCityManually => 'Pilih kota secara manual';

  @override
  String get permissionDeniedMessage =>
      'Ketuk Izinkan lokasi lalu pilih Izinkan saat diminta, atau pilih kota Anda secara manual.';

  @override
  String get permissionBlockedTitle => 'Izin lokasi diblokir';

  @override
  String get permissionBlockedMessage =>
      'Aktifkan izin lokasi untuk Deenly di pengaturan perangkat, lalu kembali ke aplikasi.';

  @override
  String get permissionOpenSettings => 'Buka pengaturan';

  @override
  String get permissionNotificationTitle => 'Jangan lewatkan waktu sholat';

  @override
  String get permissionNotificationSubtitle =>
      'Izinkan notifikasi agar Deenly dapat mengingatkan Anda saat waktu sholat tiba.';

  @override
  String get permissionReasonAdhanTitle => 'Notifikasi adzan';

  @override
  String get permissionReasonAdhanBody =>
      'Notifikasi di awal setiap waktu sholat.';

  @override
  String get permissionReasonReminderTitle => 'Pengingat sholat';

  @override
  String get permissionReasonReminderBody =>
      'Pengingat opsional 10 menit sebelum setiap waktu sholat.';

  @override
  String get permissionNotificationHint =>
      'Anda bisa mengubahnya kapan saja di Pengaturan.';

  @override
  String get permissionAllowNotification => 'Izinkan notifikasi';

  @override
  String get permissionNotNow => 'Nanti saja';

  @override
  String get jumpToAyah => 'Lompat ke Ayat';

  @override
  String jumpToAyahHint(int total) {
    return 'Nomor ayat (1–$total)';
  }

  @override
  String jumpToAyahInvalid(int total) {
    return 'Masukkan angka antara 1 dan $total';
  }

  @override
  String get jumpToAyahGo => 'Buka';

  @override
  String get nearbyMosques => 'Masjid Terdekat';

  @override
  String get qiblaDirection => 'Arah Kiblat';

  @override
  String nextPrayerIn(String prayer) {
    return '$prayer dimulai dalam';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours jam $minutes menit';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes menit';
  }

  @override
  String get imsak => 'Imsak';

  @override
  String get sunrise => 'Terbit';

  @override
  String get prayerNow => 'Sekarang';

  @override
  String prayerStartsIn(String duration) {
    return '$duration lagi';
  }

  @override
  String get backToToday => 'Kembali ke hari ini';

  @override
  String get previousDay => 'Hari sebelumnya';

  @override
  String get nextDay => 'Hari berikutnya';

  @override
  String get chooseDate => 'Pilih tanggal';

  @override
  String get prayerScheduleEmpty =>
      'Jadwal shalat untuk tanggal ini belum tersedia';

  @override
  String get adhanOn => 'Notifikasi adzan aktif';

  @override
  String get adhanOff => 'Notifikasi adzan nonaktif';

  @override
  String get prayerNotYet => 'Belum masuk waktu shalat';

  @override
  String prayerTrackLocked(int days) {
    return 'Hanya bisa ditandai sampai $days hari ke belakang';
  }

  @override
  String get prayerHistory => 'Riwayat Shalat';

  @override
  String streakDays(int count) {
    return '$count hari beruntun';
  }

  @override
  String historyRate(int percent, int days) {
    return '$percent% terlaksana dalam $days hari terakhir';
  }

  @override
  String get jumuah => 'Jumat';

  @override
  String get notificationMarkDone => 'Sudah shalat';

  @override
  String get settingMissedTitle => 'Pengingat jika belum shalat';

  @override
  String notificationMissedTitle(String prayer) {
    return 'Sudah shalat $prayer?';
  }

  @override
  String get notificationMissedBody =>
      'Tandai jika sudah, supaya progresmu tercatat';
}
