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
  String get doaLoadFailed => 'Gagal memuat doa.';

  @override
  String doaCount(int count) {
    return '$count doa';
  }

  @override
  String get dzikirLoadFailed => 'Gagal memuat dzikir.';

  @override
  String dzikirCount(int count) {
    return '$count dzikir';
  }

  @override
  String dzikirTimes(int count) {
    return '${count}x';
  }

  @override
  String dzikirProgress(int done, int total) {
    return '$done dari $total selesai';
  }

  @override
  String get dzikirTapHint => 'Ketuk untuk hitung, tahan untuk reset';

  @override
  String get dzikirAllDone => 'Semua dzikir selesai';

  @override
  String get dzikirRestart => 'Ulangi dari awal';

  @override
  String get dzikirRestartConfirm =>
      'Semua hitungan di kategori ini akan direset.';

  @override
  String get dzikirItemReset => 'Hitungan direset';

  @override
  String get dzikirVirtue => 'Keutamaan';

  @override
  String get dzikirReminderMorning => 'Waktunya Dzikir Pagi';

  @override
  String get dzikirReminderEvening => 'Waktunya Dzikir Petang';

  @override
  String get dzikirReminderStart => 'Mulai Dzikir';

  @override
  String get dzikirReminderVerse =>
      '“Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.”';

  @override
  String get dzikirReminderVerseSource => '(QS. Ar-Ra\'d: 28)';

  @override
  String dzikirReminderUntil(String time) {
    return 'Sampai pukul $time';
  }

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
  String get settingDzikirTitle => 'Pengingat dzikir pagi & petang';

  @override
  String get notificationDzikirMorningBody =>
      'Luangkan beberapa menit untuk dzikir pagi sebelum matahari terbit';

  @override
  String get notificationDzikirEveningBody =>
      'Luangkan beberapa menit untuk dzikir petang sebelum Maghrib';

  @override
  String get settingCalendarTitle =>
      'Pengingat kalender (malam sebelumnya, 20.00)';

  @override
  String get settingCalendarHoliday => 'Hari besar Islam';

  @override
  String get settingCalendarSunnahFast => 'Puasa sunnah';

  @override
  String calendarReminderTitle(String names) {
    return 'Besok: $names';
  }

  @override
  String get calendarReminderFastingBody =>
      'Jangan lupa niat dan siapkan sahur.';

  @override
  String calendarReminderHolidayBody(String date) {
    return 'Besok bertepatan dengan $date.';
  }

  @override
  String get calendarReminderEstimate =>
      'Tanggal masih perkiraan, tunggu hasil sidang isbat.';

  @override
  String get calendarReminderMondayFast => 'Puasa Senin';

  @override
  String get calendarReminderThursdayFast => 'Puasa Kamis';

  @override
  String notificationMissedTitle(String prayer) {
    return 'Sudah shalat $prayer?';
  }

  @override
  String get notificationMissedBody =>
      'Tandai jika sudah, supaya progresmu tercatat';

  @override
  String get zakatNisabYearly => 'Nisab per tahun';

  @override
  String zakatNisabInfo(String decree) {
    return 'Setara 85 gr emas · $decree';
  }

  @override
  String zakatDecree(String number, String year) {
    return 'SK Ketua BAZNAS No. $number Tahun $year';
  }

  @override
  String get zakatGoldPricePerGram => 'Harga emas per gram';

  @override
  String get zakatSilverPricePerGram => 'Harga perak per gram';

  @override
  String get zakatMetalPriceNote =>
      'Harga awal mengikuti harga spot internasional. Ubah jika harga di tempatmu berbeda.';

  @override
  String get zakatPriceStale =>
      'Gagal memperbarui harga emas, memakai harga terakhir.';

  @override
  String get zakatPriceDefault =>
      'Harga emas belum tersedia, memakai harga default.';

  @override
  String zakatPriceSource(String source, String date) {
    return 'Harga awal dari $source, diperbarui $date.';
  }

  @override
  String get zakatPriceSourceDefault => 'harga default aplikasi';

  @override
  String get zakatCalculators => 'Kalkulator Zakat';

  @override
  String get zakatGuide => 'Panduan Zakat';

  @override
  String get zakatGuideLoadFailed => 'Gagal memuat panduan zakat.';

  @override
  String get zakatNiat => 'Niat & Doa';

  @override
  String get zakatNiatLoadFailed => 'Gagal memuat niat zakat.';

  @override
  String zakatGuideSource(String name) {
    return 'Sumber: $name';
  }

  @override
  String zakatVerseReference(String surah, int number, int ayah) {
    return 'QS. $surah ($number): $ayah';
  }

  @override
  String get zakatFitrah => 'Zakat Fitrah';

  @override
  String get zakatFitrahDesc => 'Wajib bagi setiap jiwa sebelum Idul Fitri';

  @override
  String get zakatIncome => 'Zakat Penghasilan';

  @override
  String get zakatIncomeDesc => 'Dari gaji dan pendapatan bulanan lainnya';

  @override
  String get zakatMaal => 'Zakat Maal';

  @override
  String get zakatMaalDesc => 'Tabungan, deposito, dan investasi';

  @override
  String get zakatGoldSilver => 'Zakat Emas & Perak';

  @override
  String get zakatGoldSilverDesc => 'Emas dan perak yang disimpan';

  @override
  String get zakatTrade => 'Zakat Perdagangan';

  @override
  String get zakatTradeDesc => 'Modal usaha, laba dan piutang';

  @override
  String get zakatTradeCapital => 'Modal (kas dan stok barang)';

  @override
  String get zakatTradeProfit => 'Laba';

  @override
  String get zakatTradeReceivables => 'Piutang yang lancar';

  @override
  String get zakatTotalTradeAssets => 'Total aset usaha';

  @override
  String get zakatFidyah => 'Fidyah';

  @override
  String get zakatFidyahDesc => 'Pengganti puasa yang tidak bisa diqadha';

  @override
  String get zakatFidyahDays => 'Jumlah hari puasa yang ditinggalkan';

  @override
  String get zakatFidyahPerDay => 'Nominal per hari';

  @override
  String zakatFidyahNote(String decree) {
    return 'Per hari untuk satu orang, sesuai $decree. Sesuaikan jika ketetapan BAZNAS daerahmu berbeda.';
  }

  @override
  String get zakatFidyahAmount => 'Fidyah yang dibayar';

  @override
  String zakatDaysTimes(int days, String amount) {
    return '$days hari × $amount';
  }

  @override
  String get zakatDisclaimer =>
      'Hasil perhitungan bersifat estimasi. Untuk kepastian, rujuk BAZNAS atau Lembaga Amil Zakat (LAZ) resmi.';

  @override
  String get zakatPeople => 'Jumlah jiwa';

  @override
  String get zakatPayWith => 'Bayar dengan';

  @override
  String get zakatRice => 'Beras';

  @override
  String get zakatMoney => 'Uang';

  @override
  String get zakatFitrahPerPerson => 'Nominal per jiwa';

  @override
  String zakatFitrahNote(String decree) {
    return 'Sesuai $decree. Sesuaikan jika ketetapan BAZNAS daerahmu berbeda.';
  }

  @override
  String get zakatRiceUnit => 'Takaran';

  @override
  String get zakatKilogram => 'Kilogram';

  @override
  String get zakatLiterUnit => 'Liter';

  @override
  String zakatLiter(String amount) {
    return '$amount liter';
  }

  @override
  String zakatKg(String amount) {
    return '$amount kg';
  }

  @override
  String zakatPeopleTimes(int people, String amount) {
    return '$people jiwa × $amount';
  }

  @override
  String get zakatMonthlyIncome => 'Penghasilan per bulan';

  @override
  String get zakatOtherIncome => 'Penghasilan lain per bulan (bonus, dll.)';

  @override
  String zakatIncomeNisabNote(String nisab) {
    return 'Nisab bulanan: $nisab (85 gr emas ÷ 12)';
  }

  @override
  String get zakatSavings => 'Tabungan';

  @override
  String get zakatDeposits => 'Deposito';

  @override
  String get zakatInvestments => 'Investasi (saham, reksa dana, dll.)';

  @override
  String get zakatDebts => 'Utang jatuh tempo';

  @override
  String get zakatHaul => 'Sudah dimiliki 1 tahun (haul)';

  @override
  String get zakatHaulHint =>
      'Zakat wajib setelah harta dimiliki selama satu tahun hijriah.';

  @override
  String get zakatGold => 'Emas';

  @override
  String get zakatSilver => 'Perak';

  @override
  String get zakatGoldGrams => 'Emas yang disimpan';

  @override
  String get zakatSilverGrams => 'Perak yang disimpan';

  @override
  String get zakatGramSuffix => 'gr';

  @override
  String get zakatResult => 'Hasil Perhitungan';

  @override
  String get zakatStatusObligatory => 'Wajib zakat';

  @override
  String get zakatStatusBelowNisab => 'Belum mencapai nisab';

  @override
  String get zakatStatusNotHaul => 'Belum mencapai haul';

  @override
  String get zakatAmount => 'Zakat yang harus dibayar';

  @override
  String get zakatTotalIncome => 'Total penghasilan';

  @override
  String get zakatTotalWealth => 'Total harta';

  @override
  String get zakatNisab => 'Nisab';

  @override
  String get zakatFormula => 'Rumus';

  @override
  String zakatRateFormula(String base) {
    return '$base × 2,5%';
  }

  @override
  String get zakatFillHint => 'Isi data di atas untuk melihat hasil.';

  @override
  String get hijriMuharram => 'Muharram';

  @override
  String get hijriSafar => 'Safar';

  @override
  String get hijriRabiulAwal => 'Rabiul Awal';

  @override
  String get hijriRabiulAkhir => 'Rabiul Akhir';

  @override
  String get hijriJumadilAwal => 'Jumadil Awal';

  @override
  String get hijriJumadilAkhir => 'Jumadil Akhir';

  @override
  String get hijriRajab => 'Rajab';

  @override
  String get hijriShaban => 'Sya\'ban';

  @override
  String get hijriRamadan => 'Ramadhan';

  @override
  String get hijriShawwal => 'Syawal';

  @override
  String get hijriDhulQadah => 'Dzulqa\'dah';

  @override
  String get hijriDhulHijjah => 'Dzulhijjah';

  @override
  String calendarHijriDate(int day, String month, int year) {
    return '$day $month $year H';
  }

  @override
  String calendarHijriMonthYear(String month, int year) {
    return '$month $year H';
  }

  @override
  String get calendarToday => 'Hari ini';

  @override
  String get calendarNextEvent => 'Hari besar berikutnya';

  @override
  String calendarDaysLeft(int count) {
    return '$count hari lagi';
  }

  @override
  String get calendarGregorian => 'Masehi';

  @override
  String get calendarHijri => 'Hijriah';

  @override
  String get calendarPreviousMonth => 'Bulan sebelumnya';

  @override
  String get calendarNextMonth => 'Bulan berikutnya';

  @override
  String get calendarMonthEvents => 'Peristiwa bulan ini';

  @override
  String get calendarNoEvents => 'Tidak ada peristiwa khusus bulan ini.';

  @override
  String get calendarLegendHoliday => 'Hari besar Islam';

  @override
  String get calendarLegendSunnahFast => 'Puasa sunnah';

  @override
  String get calendarLegendForbiddenFast => 'Dilarang puasa';

  @override
  String get calendarAdjustment => 'Penyesuaian tanggal Hijriah';

  @override
  String get calendarAdjustmentHint =>
      'Tanggal Hijriah dihitung secara hisab dan bisa berbeda 1–2 hari dengan hasil rukyat resmi. Geser agar sesuai dengan penetapan di daerahmu.';

  @override
  String get calendarAdjustmentOfficialNote =>
      'Bulan yang sudah ditetapkan lewat sidang isbat mengikuti tanggal resmi dan tidak ikut digeser.';

  @override
  String get updateRequiredTitle => 'Perlu pembaruan';

  @override
  String get updateRequiredMessage =>
      'Versi Deenly ini sudah tidak didukung. Perbarui aplikasi untuk melanjutkan.';

  @override
  String get updateRequiredButton => 'Perbarui sekarang';

  @override
  String get updateRequiredOpenFailed =>
      'Tidak bisa membuka halaman pembaruan.';

  @override
  String calendarAdjustmentDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days hari',
      zero: 'Tanpa penyesuaian',
    );
    return '$_temp0';
  }

  @override
  String get calendarNoPractice => 'Tidak ada peristiwa khusus di hari ini.';

  @override
  String get calendarMondayThursdayFast => 'Puasa Senin & Kamis';

  @override
  String get calendarMondayThursdayFastDesc =>
      'Amal diperlihatkan kepada Allah setiap Senin dan Kamis, dan Nabi ﷺ senang saat itu beliau sedang berpuasa (HR. Tirmidzi).';

  @override
  String get calendarRamadanFast => 'Puasa Ramadhan';

  @override
  String get calendarRamadanFastDesc =>
      'Puasa sebulan penuh di bulan Ramadhan wajib bagi setiap muslim yang baligh.';

  @override
  String get calendarPrayerTimes => 'Jadwal sholat';

  @override
  String get calendarPrayerUnavailable =>
      'Jadwal sholat untuk tanggal ini belum tersedia.';
}
