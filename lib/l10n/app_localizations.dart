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

  /// No description provided for @menuPrayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get menuPrayers;

  /// No description provided for @menuDoa.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get menuDoa;

  /// No description provided for @menuAsmaulHusna.
  ///
  /// In en, this message translates to:
  /// **'Asmaul Husna'**
  String get menuAsmaulHusna;

  /// No description provided for @menuDzikir.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get menuDzikir;

  /// No description provided for @menuCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get menuCalendar;

  /// No description provided for @menuZakat.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get menuZakat;

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

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

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

  /// No description provided for @settingAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingAboutTitle;

  /// No description provided for @settingPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingPrivacyPolicy;

  /// No description provided for @searchSurahHint.
  ///
  /// In en, this message translates to:
  /// **'Surah name or number...'**
  String get searchSurahHint;

  /// No description provided for @surahList.
  ///
  /// In en, this message translates to:
  /// **'Surah List'**
  String get surahList;

  /// No description provided for @filterByJuz.
  ///
  /// In en, this message translates to:
  /// **'Filter by : Juz'**
  String get filterByJuz;

  /// No description provided for @filterBySurah.
  ///
  /// In en, this message translates to:
  /// **'Filter by : Surah'**
  String get filterBySurah;

  /// Ayah indicator with number
  ///
  /// In en, this message translates to:
  /// **'Ayat {number}'**
  String ayahCount(String number);

  /// No description provided for @noSurahFound.
  ///
  /// In en, this message translates to:
  /// **'No Surah found'**
  String get noSurahFound;

  /// No description provided for @noJuzFound.
  ///
  /// In en, this message translates to:
  /// **'No Juz found'**
  String get noJuzFound;

  /// Juz header with number
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juzNumber(String number);

  /// Ayah range for a juz
  ///
  /// In en, this message translates to:
  /// **'Ayah {from} - {to}'**
  String ayahRange(String from, String to);

  /// No description provided for @failedFetchSurahDetail.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch surah detail'**
  String get failedFetchSurahDetail;

  /// No description provided for @continueScrollNextSurah.
  ///
  /// In en, this message translates to:
  /// **'Continue scrolling down to move to the next surah'**
  String get continueScrollNextSurah;

  /// No description provided for @prayerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load prayer times. Check your internet connection and location, then try again.'**
  String get prayerLoadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @approximateLocationNotice.
  ///
  /// In en, this message translates to:
  /// **'Approximate times based on your time zone ({city}). Turn on GPS for accurate times.'**
  String approximateLocationNotice(String city);

  /// No description provided for @chooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose city'**
  String get chooseCity;

  /// No description provided for @cityNameHint.
  ///
  /// In en, this message translates to:
  /// **'City name'**
  String get cityNameHint;

  /// No description provided for @cityNotFound.
  ///
  /// In en, this message translates to:
  /// **'City not found or no internet connection.'**
  String get cityNotFound;

  /// No description provided for @useCity.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get useCity;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied forever, please enable it in settings'**
  String get locationPermissionDeniedForever;

  /// No description provided for @assalamuAlaikum.
  ///
  /// In en, this message translates to:
  /// **'Assalamu Alaikum,'**
  String get assalamuAlaikum;

  /// No description provided for @noMosqueFound.
  ///
  /// In en, this message translates to:
  /// **'No mosques found within 2 km.'**
  String get noMosqueFound;

  /// No description provided for @couldNotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps.'**
  String get couldNotOpenMaps;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get couldNotOpenLink;

  /// No description provided for @notificationScheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to schedule notification'**
  String get notificationScheduleFailed;

  /// No description provided for @reminderEnableFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not enable reminder'**
  String get reminderEnableFailed;

  /// No description provided for @adjustmentSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save prayer time adjustments'**
  String get adjustmentSaveFailed;

  /// No description provided for @notificationAdhanTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhan Reminder'**
  String get notificationAdhanTitle;

  /// No description provided for @notificationAdhanBody.
  ///
  /// In en, this message translates to:
  /// **'It is time for {prayer} prayer'**
  String notificationAdhanBody(String prayer);

  /// No description provided for @notificationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminder'**
  String get notificationReminderTitle;

  /// No description provided for @notificationReminderBody.
  ///
  /// In en, this message translates to:
  /// **'10 minutes until {prayer} prayer'**
  String notificationReminderBody(String prayer);

  /// No description provided for @qiblaNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Location is not available yet. Turn on GPS or choose a city on the Home page.'**
  String get qiblaNoLocation;

  /// No description provided for @mosqueLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location. Make sure GPS is on and location permission is granted.'**
  String get mosqueLocationUnavailable;

  /// No description provided for @mosqueLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load nearby mosques.'**
  String get mosqueLoadFailed;

  /// No description provided for @asmaulHusnaLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Asmaul Husna.'**
  String get asmaulHusnaLoadFailed;

  /// No description provided for @doaLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load duas.'**
  String get doaLoadFailed;

  /// No description provided for @doaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dua} other{{count} duas}}'**
  String doaCount(int count);

  /// No description provided for @dzikirLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dhikr.'**
  String get dzikirLoadFailed;

  /// No description provided for @dzikirCount.
  ///
  /// In en, this message translates to:
  /// **'{count} dhikr'**
  String dzikirCount(int count);

  /// No description provided for @dzikirTimes.
  ///
  /// In en, this message translates to:
  /// **'{count}x'**
  String dzikirTimes(int count);

  /// No description provided for @dzikirProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String dzikirProgress(int done, int total);

  /// No description provided for @dzikirTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to count'**
  String get dzikirTapHint;

  /// No description provided for @dzikirAllDone.
  ///
  /// In en, this message translates to:
  /// **'All dhikr completed'**
  String get dzikirAllDone;

  /// No description provided for @dzikirVirtue.
  ///
  /// In en, this message translates to:
  /// **'Virtue'**
  String get dzikirVirtue;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Deenly'**
  String get appTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'A companion for the modern Muslim'**
  String get splashTagline;

  /// No description provided for @permissionLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable location for accurate prayer times'**
  String get permissionLocationTitle;

  /// No description provided for @permissionLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deenly uses your location to calculate prayer times, find the Qibla and show mosques near you.'**
  String get permissionLocationSubtitle;

  /// No description provided for @permissionReasonPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Accurate prayer times'**
  String get permissionReasonPrayerTitle;

  /// No description provided for @permissionReasonPrayerBody.
  ///
  /// In en, this message translates to:
  /// **'Fajr to Isha times calculated for where you are.'**
  String get permissionReasonPrayerBody;

  /// No description provided for @permissionReasonQiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla direction'**
  String get permissionReasonQiblaTitle;

  /// No description provided for @permissionReasonQiblaBody.
  ///
  /// In en, this message translates to:
  /// **'A compass pointing toward the Kaaba from your position.'**
  String get permissionReasonQiblaBody;

  /// No description provided for @permissionReasonMosqueTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby mosques'**
  String get permissionReasonMosqueTitle;

  /// No description provided for @permissionReasonMosqueBody.
  ///
  /// In en, this message translates to:
  /// **'Mosques within 2 km and how far they are from you.'**
  String get permissionReasonMosqueBody;

  /// No description provided for @permissionLocationPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your location is only used for prayer times, the Qibla and nearby mosques.'**
  String get permissionLocationPrivacy;

  /// No description provided for @permissionAllowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get permissionAllowLocation;

  /// No description provided for @permissionChooseCityManually.
  ///
  /// In en, this message translates to:
  /// **'Choose city manually'**
  String get permissionChooseCityManually;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap Allow location and choose Allow when asked, or choose your city manually.'**
  String get permissionDeniedMessage;

  /// No description provided for @permissionBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked'**
  String get permissionBlockedTitle;

  /// No description provided for @permissionBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable location for Deenly in your device settings, then return to the app.'**
  String get permissionBlockedMessage;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permissionOpenSettings;

  /// No description provided for @permissionNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a prayer'**
  String get permissionNotificationTitle;

  /// No description provided for @permissionNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so Deenly can remind you when each prayer time begins.'**
  String get permissionNotificationSubtitle;

  /// No description provided for @permissionReasonAdhanTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhan notifications'**
  String get permissionReasonAdhanTitle;

  /// No description provided for @permissionReasonAdhanBody.
  ///
  /// In en, this message translates to:
  /// **'A notification at the start of every prayer time.'**
  String get permissionReasonAdhanBody;

  /// No description provided for @permissionReasonReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders'**
  String get permissionReasonReminderTitle;

  /// No description provided for @permissionReasonReminderBody.
  ///
  /// In en, this message translates to:
  /// **'An optional reminder 10 minutes before each prayer.'**
  String get permissionReasonReminderBody;

  /// No description provided for @permissionNotificationHint.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings.'**
  String get permissionNotificationHint;

  /// No description provided for @permissionAllowNotification.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get permissionAllowNotification;

  /// No description provided for @permissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permissionNotNow;

  /// No description provided for @jumpToAyah.
  ///
  /// In en, this message translates to:
  /// **'Jump to Ayah'**
  String get jumpToAyah;

  /// No description provided for @jumpToAyahHint.
  ///
  /// In en, this message translates to:
  /// **'Ayah number (1–{total})'**
  String jumpToAyahHint(int total);

  /// No description provided for @jumpToAyahInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 1 and {total}'**
  String jumpToAyahInvalid(int total);

  /// No description provided for @jumpToAyahGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get jumpToAyahGo;

  /// No description provided for @nearbyMosques.
  ///
  /// In en, this message translates to:
  /// **'Nearby Mosques'**
  String get nearbyMosques;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @nextPrayerIn.
  ///
  /// In en, this message translates to:
  /// **'{prayer} begins in'**
  String nextPrayerIn(String prayer);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @imsak.
  ///
  /// In en, this message translates to:
  /// **'Imsak'**
  String get imsak;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @prayerNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get prayerNow;

  /// No description provided for @prayerStartsIn.
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String prayerStartsIn(String duration);

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get backToToday;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @prayerScheduleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Prayer times for this date are not available yet'**
  String get prayerScheduleEmpty;

  /// No description provided for @adhanOn.
  ///
  /// In en, this message translates to:
  /// **'Adhan notification on'**
  String get adhanOn;

  /// No description provided for @adhanOff.
  ///
  /// In en, this message translates to:
  /// **'Adhan notification off'**
  String get adhanOff;

  /// No description provided for @prayerNotYet.
  ///
  /// In en, this message translates to:
  /// **'It is not prayer time yet'**
  String get prayerNotYet;

  /// No description provided for @prayerTrackLocked.
  ///
  /// In en, this message translates to:
  /// **'Only the last {days} days can be marked'**
  String prayerTrackLocked(int days);

  /// No description provided for @prayerHistory.
  ///
  /// In en, this message translates to:
  /// **'Prayer History'**
  String get prayerHistory;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String streakDays(int count);

  /// No description provided for @historyRate.
  ///
  /// In en, this message translates to:
  /// **'{percent}% done in the last {days} days'**
  String historyRate(int percent, int days);

  /// No description provided for @jumuah.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'ah'**
  String get jumuah;

  /// No description provided for @notificationMarkDone.
  ///
  /// In en, this message translates to:
  /// **'I have prayed'**
  String get notificationMarkDone;

  /// No description provided for @settingMissedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder if not prayed yet'**
  String get settingMissedTitle;

  /// No description provided for @notificationMissedTitle.
  ///
  /// In en, this message translates to:
  /// **'Have you prayed {prayer}?'**
  String notificationMissedTitle(String prayer);

  /// No description provided for @notificationMissedBody.
  ///
  /// In en, this message translates to:
  /// **'Mark it once you have, so your progress is recorded'**
  String get notificationMissedBody;
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
