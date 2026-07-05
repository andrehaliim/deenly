import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @nextPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayerTitle;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get menuQuran;

  /// No description provided for @menuMosque.
  ///
  /// In en, this message translates to:
  /// **'Mosque'**
  String get menuMosque;

  /// No description provided for @menuQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get menuQibla;

  /// No description provided for @menuTasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get menuTasbih;

  /// No description provided for @menuSetting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSetting;

  /// No description provided for @prayerProgress.
  ///
  /// In en, this message translates to:
  /// **'Prayer Progress'**
  String get prayerProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @hadithTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Hadith'**
  String get hadithTitle;

  /// No description provided for @hadithNarrated.
  ///
  /// In en, this message translates to:
  /// **'Narrated by: '**
  String get hadithNarrated;

  /// No description provided for @continueRead.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueRead;

  /// No description provided for @continueAyah.
  ///
  /// In en, this message translates to:
  /// **'Ayah No: '**
  String get continueAyah;

  /// No description provided for @ayah.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get ayah;

  /// No description provided for @mosqueTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get mosqueTryAgain;

  /// No description provided for @mosqueLoadAddress.
  ///
  /// In en, this message translates to:
  /// **'Loading Address...'**
  String get mosqueLoadAddress;

  /// Instruction to rotate phone to align with Qibla direction
  ///
  /// In en, this message translates to:
  /// **'Rotate the phone {degree}° to the {direction}'**
  String qiblaRotate(String degree, String direction);

  /// No description provided for @qiblaFacing.
  ///
  /// In en, this message translates to:
  /// **'You are facing the Qibla!'**
  String get qiblaFacing;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'right'**
  String get right;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get left;

  /// No description provided for @errorRead.
  ///
  /// In en, this message translates to:
  /// **'Error reading compass'**
  String get errorRead;

  /// No description provided for @errorNotSupport.
  ///
  /// In en, this message translates to:
  /// **'Error: This device does not support the compass'**
  String get errorNotSupport;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Session'**
  String get sessionTitle;

  /// No description provided for @sessionSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Target'**
  String get sessionSelect;

  /// No description provided for @sessionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Counter'**
  String get sessionReset;

  /// No description provided for @sessionTap.
  ///
  /// In en, this message translates to:
  /// **'Taps'**
  String get sessionTap;

  /// No description provided for @settingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguageTitle;

  /// No description provided for @settingAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingAppearanceTitle;

  /// No description provided for @settingTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingTheme;

  /// No description provided for @settingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Notifications'**
  String get settingNotificationTitle;

  /// No description provided for @settingTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Adjustment'**
  String get settingTimeTitle;

  /// No description provided for @settingSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingSaveButton;

  /// No description provided for @settingBeforeTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification before adhan'**
  String get settingBeforeTitle;

  /// No description provided for @settingBeforeValue.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get settingBeforeValue;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
