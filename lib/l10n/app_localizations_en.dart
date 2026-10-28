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
  String get menuPrayers => 'Prayers';

  @override
  String get menuDoa => 'Dua';

  @override
  String get menuAsmaulHusna => 'Asmaul Husna';

  @override
  String get menuDzikir => 'Dhikr';

  @override
  String get menuCalendar => 'Calendar';

  @override
  String get menuZakat => 'Zakat';

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
  String get settingAboutTitle => 'About';

  @override
  String get settingPrivacyPolicy => 'Privacy Policy';

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
  String get couldNotOpenLink => 'Could not open the link.';

  @override
  String get notificationScheduleFailed => 'Failed to schedule notification';

  @override
  String get reminderEnableFailed => 'Could not enable reminder';

  @override
  String get adjustmentSaveFailed => 'Failed to save prayer time adjustments';

  @override
  String get notificationAdhanTitle => 'Adhan Reminder';

  @override
  String notificationAdhanBody(String prayer) {
    return 'It is time for $prayer prayer';
  }

  @override
  String get notificationReminderTitle => 'Prayer Reminder';

  @override
  String notificationReminderBody(String prayer) {
    return '10 minutes until $prayer prayer';
  }

  @override
  String get qiblaNoLocation =>
      'Location is not available yet. Turn on GPS or choose a city on the Home page.';

  @override
  String get mosqueLocationUnavailable =>
      'Could not get your location. Make sure GPS is on and location permission is granted.';

  @override
  String get mosqueLoadFailed => 'Failed to load nearby mosques.';

  @override
  String get asmaulHusnaLoadFailed => 'Failed to load Asmaul Husna.';

  @override
  String get doaLoadFailed => 'Failed to load duas.';

  @override
  String doaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duas',
      one: '1 dua',
    );
    return '$_temp0';
  }

  @override
  String get dzikirLoadFailed => 'Failed to load dhikr.';

  @override
  String dzikirCount(int count) {
    return '$count dhikr';
  }

  @override
  String dzikirTimes(int count) {
    return '${count}x';
  }

  @override
  String dzikirProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get dzikirTapHint => 'Tap a card to count';

  @override
  String get dzikirAllDone => 'All dhikr completed';

  @override
  String get dzikirVirtue => 'Virtue';

  @override
  String get appTitle => 'Deenly';

  @override
  String get splashTagline => 'A companion for the modern Muslim';

  @override
  String get permissionLocationTitle =>
      'Enable location for accurate prayer times';

  @override
  String get permissionLocationSubtitle =>
      'Deenly uses your location to calculate prayer times, find the Qibla and show mosques near you.';

  @override
  String get permissionReasonPrayerTitle => 'Accurate prayer times';

  @override
  String get permissionReasonPrayerBody =>
      'Fajr to Isha times calculated for where you are.';

  @override
  String get permissionReasonQiblaTitle => 'Qibla direction';

  @override
  String get permissionReasonQiblaBody =>
      'A compass pointing toward the Kaaba from your position.';

  @override
  String get permissionReasonMosqueTitle => 'Nearby mosques';

  @override
  String get permissionReasonMosqueBody =>
      'Mosques within 2 km and how far they are from you.';

  @override
  String get permissionLocationPrivacy =>
      'Your location is only used for prayer times, the Qibla and nearby mosques.';

  @override
  String get permissionAllowLocation => 'Allow location';

  @override
  String get permissionChooseCityManually => 'Choose city manually';

  @override
  String get permissionDeniedMessage =>
      'Tap Allow location and choose Allow when asked, or choose your city manually.';

  @override
  String get permissionBlockedTitle => 'Location permission is blocked';

  @override
  String get permissionBlockedMessage =>
      'Enable location for Deenly in your device settings, then return to the app.';

  @override
  String get permissionOpenSettings => 'Open settings';

  @override
  String get permissionNotificationTitle => 'Never miss a prayer';

  @override
  String get permissionNotificationSubtitle =>
      'Allow notifications so Deenly can remind you when each prayer time begins.';

  @override
  String get permissionReasonAdhanTitle => 'Adhan notifications';

  @override
  String get permissionReasonAdhanBody =>
      'A notification at the start of every prayer time.';

  @override
  String get permissionReasonReminderTitle => 'Prayer reminders';

  @override
  String get permissionReasonReminderBody =>
      'An optional reminder 10 minutes before each prayer.';

  @override
  String get permissionNotificationHint =>
      'You can change this anytime in Settings.';

  @override
  String get permissionAllowNotification => 'Allow notifications';

  @override
  String get permissionNotNow => 'Not now';

  @override
  String get jumpToAyah => 'Jump to Ayah';

  @override
  String jumpToAyahHint(int total) {
    return 'Ayah number (1–$total)';
  }

  @override
  String jumpToAyahInvalid(int total) {
    return 'Enter a number between 1 and $total';
  }

  @override
  String get jumpToAyahGo => 'Go';

  @override
  String get nearbyMosques => 'Nearby Mosques';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String nextPrayerIn(String prayer) {
    return '$prayer begins in';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get imsak => 'Imsak';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get prayerNow => 'Now';

  @override
  String prayerStartsIn(String duration) {
    return 'in $duration';
  }

  @override
  String get backToToday => 'Back to today';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get prayerScheduleEmpty =>
      'Prayer times for this date are not available yet';

  @override
  String get adhanOn => 'Adhan notification on';

  @override
  String get adhanOff => 'Adhan notification off';

  @override
  String get prayerNotYet => 'It is not prayer time yet';

  @override
  String prayerTrackLocked(int days) {
    return 'Only the last $days days can be marked';
  }

  @override
  String get prayerHistory => 'Prayer History';

  @override
  String streakDays(int count) {
    return '$count day streak';
  }

  @override
  String historyRate(int percent, int days) {
    return '$percent% done in the last $days days';
  }

  @override
  String get jumuah => 'Jumu\'ah';

  @override
  String get notificationMarkDone => 'I have prayed';

  @override
  String get settingMissedTitle => 'Reminder if not prayed yet';

  @override
  String notificationMissedTitle(String prayer) {
    return 'Have you prayed $prayer?';
  }

  @override
  String get notificationMissedBody =>
      'Mark it once you have, so your progress is recorded';

  @override
  String get zakatNisabToday => 'Today\'s nisab';

  @override
  String zakatNisabInfo(String price) {
    return 'Equal to 85 g of gold · $price/g';
  }

  @override
  String get zakatPriceStale =>
      'Could not update the gold price, showing the last saved price.';

  @override
  String get zakatPriceDefault =>
      'Gold price unavailable, showing the BAZNAS default nisab.';

  @override
  String get zakatCalculators => 'Zakat Calculator';

  @override
  String get zakatFitrah => 'Zakat Fitrah';

  @override
  String get zakatFitrahDesc => 'Due for every person before Eid al-Fitr';

  @override
  String get zakatIncome => 'Income Zakat';

  @override
  String get zakatIncomeDesc => 'From salary and other monthly income';

  @override
  String get zakatMaal => 'Zakat Maal';

  @override
  String get zakatMaalDesc => 'Savings, deposits and investments';

  @override
  String get zakatGoldSilver => 'Gold & Silver Zakat';

  @override
  String get zakatGoldSilverDesc => 'Gold and silver you keep';

  @override
  String get zakatDisclaimer =>
      'Results are estimates. For certainty, consult BAZNAS or an official zakat institution (LAZ).';

  @override
  String get zakatPeople => 'Number of people';

  @override
  String get zakatPayWith => 'Pay with';

  @override
  String get zakatRice => 'Rice';

  @override
  String get zakatMoney => 'Money';

  @override
  String get zakatFitrahPerPerson => 'Amount per person';

  @override
  String zakatKg(String amount) {
    return '$amount kg';
  }

  @override
  String zakatPeopleTimes(int people, String amount) {
    return '$people people × $amount';
  }

  @override
  String get zakatMonthlyIncome => 'Monthly income';

  @override
  String get zakatOtherIncome => 'Other monthly income (bonus, etc.)';

  @override
  String zakatIncomeNisabNote(String nisab) {
    return 'Monthly nisab: $nisab (85 g of gold ÷ 12)';
  }

  @override
  String get zakatSavings => 'Savings';

  @override
  String get zakatDeposits => 'Deposits';

  @override
  String get zakatInvestments => 'Investments (stocks, mutual funds, etc.)';

  @override
  String get zakatDebts => 'Debts due';

  @override
  String get zakatHaul => 'Held for one year (haul)';

  @override
  String get zakatHaulHint =>
      'Zakat is due once the wealth has been held for one lunar year.';

  @override
  String get zakatGold => 'Gold';

  @override
  String get zakatSilver => 'Silver';

  @override
  String get zakatGoldGrams => 'Gold kept';

  @override
  String get zakatSilverGrams => 'Silver kept';

  @override
  String get zakatGramSuffix => 'g';

  @override
  String get zakatResult => 'Result';

  @override
  String get zakatStatusObligatory => 'Zakat is due';

  @override
  String get zakatStatusBelowNisab => 'Below nisab';

  @override
  String get zakatStatusNotHaul => 'Haul not reached yet';

  @override
  String get zakatAmount => 'Zakat to pay';

  @override
  String get zakatTotalIncome => 'Total income';

  @override
  String get zakatTotalWealth => 'Total wealth';

  @override
  String get zakatNisab => 'Nisab';

  @override
  String get zakatFormula => 'Formula';

  @override
  String zakatRateFormula(String base) {
    return '$base × 2.5%';
  }

  @override
  String get zakatFillHint => 'Fill in the fields above to see the result.';
}
