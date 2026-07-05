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
}
