// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nextPrayerTitle => 'Next Prayer';

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get fajr => 'Fajr';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get menuHome => 'Home';

  @override
  String get menuQuran => 'Quran';

  @override
  String get menuMosque => 'Mosque';

  @override
  String get menuQibla => 'Qibla';

  @override
  String get menuTasbih => 'Tasbih';

  @override
  String get menuSetting => 'Settings';

  @override
  String get prayerProgress => 'Prayer Progress';

  @override
  String get completed => 'Completed';

  @override
  String get hadithTitle => 'Daily Hadith';

  @override
  String get hadithNarrated => 'Narrated by: ';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get continueRead => 'Continue Reading';

  @override
  String get continueAyah => 'Ayah No: ';

  @override
  String get ayah => 'Ayahs';

  @override
  String get mosqueTryAgain => 'Try Again';

  @override
  String get mosqueLoadAddress => 'Loading Address...';

  @override
  String qiblaRotate(String degree, String direction) {
    return 'Rotate the phone $degree° to the $direction';
  }

  @override
  String get qiblaFacing => 'You are facing the Qibla!';

  @override
  String get right => 'right';

  @override
  String get left => 'left';

  @override
  String get errorRead => 'Error reading compass';

  @override
  String get errorNotSupport =>
      'Error: This device does not support the compass';

  @override
  String get sessionTitle => 'Current Session';

  @override
  String get sessionSelect => 'Select Target';

  @override
  String get sessionReset => 'Reset Counter';

  @override
  String get sessionTap => 'Taps';

  @override
  String get settingLanguageTitle => 'Language';

  @override
  String get settingAppearanceTitle => 'Appearance';

  @override
  String get settingTheme => 'Dark Mode';

  @override
  String get settingNotificationTitle => 'Prayer Notifications';

  @override
  String get settingTimeTitle => 'Time Adjustment';

  @override
  String get settingSaveButton => 'Save';

  @override
  String get settingBeforeTitle => 'Notification before adhan';

  @override
  String get settingBeforeValue => 'Turn on';

  @override
  String get searchSurahHint => 'Surah name or number...';

  @override
  String get surahList => 'Surah List';

  @override
  String get filterByJuz => 'Filter by : Juz';

  @override
  String get filterBySurah => 'Filter by : Surah';

  @override
  String ayahCount(String number) {
    return 'Ayat $number';
  }

  @override
  String get noSurahFound => 'No Surah found';

  @override
  String get noJuzFound => 'No Juz found';

  @override
  String juzNumber(String number) {
    return 'Juz $number';
  }

  @override
  String ayahRange(String from, String to) {
    return 'Ayah $from - $to';
  }

  @override
  String get failedFetchSurahDetail => 'Failed to fetch surah detail';

  @override
  String get continueScrollNextSurah =>
      'Continue scrolling down to move to the next surah';

  @override
  String get prayerLoadFailed =>
      'Failed to load prayer times. Check your internet connection and location, then try again.';

  @override
  String get retry => 'Retry';

  @override
  String approximateLocationNotice(String city) {
    return 'Approximate times based on your time zone ($city). Turn on GPS for accurate times.';
  }

  @override
  String get chooseCity => 'Choose city';

  @override
  String get cityNameHint => 'City name';

  @override
  String get cityNotFound => 'City not found or no internet connection.';

  @override
  String get useCity => 'Use';

  @override
  String get cancel => 'Cancel';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission denied forever, please enable it in settings';

  @override
  String get assalamuAlaikum => 'Assalamu Alaikum,';

  @override
  String get noMosqueFound => 'No mosques found within 2 km.';

  @override
  String get couldNotOpenMaps => 'Could not open Google Maps.';

  @override
  String get notificationScheduleFailed => 'Failed to schedule notification';

  @override
  String get reminderEnableFailed => 'Could not enable reminder';

  @override
  String get appTitle => 'Deenly';

  @override
  String get splashTagline => 'A companion for the modern Muslim';
}
