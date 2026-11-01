/// A prayer time calculation authority, identified by its Aladhan method id.
class PrayerMethod {
  const PrayerMethod(this.id, this.shortName, this.name);

  final int id;
  final String shortName;
  final String name;
}

/// Picks the calculation method and Asr school for a country, following
/// the authority most Muslims there use.
class PrayerMethodHelper {
  static const int kemenag = 20;
  static const int muslimWorldLeague = 3;

  static const int schoolShafi = 0;
  static const int schoolHanafi = 1;

  /// Every method Aladhan offers, by id (see /v1/methods).
  static const List<PrayerMethod> methods = [
    PrayerMethod(0, 'Jafari', 'Shia Ithna-Ashari, Leva Institute, Qum'),
    PrayerMethod(1, 'Karachi', 'University of Islamic Sciences, Karachi'),
    PrayerMethod(2, 'ISNA', 'Islamic Society of North America (ISNA)'),
    PrayerMethod(3, 'MWL', 'Muslim World League'),
    PrayerMethod(4, 'Umm Al-Qura', 'Umm Al-Qura University, Makkah'),
    PrayerMethod(5, 'Egypt', 'Egyptian General Authority of Survey'),
    PrayerMethod(7, 'Tehran', 'Institute of Geophysics, University of Tehran'),
    PrayerMethod(8, 'Gulf', 'Gulf Region'),
    PrayerMethod(9, 'Kuwait', 'Kuwait'),
    PrayerMethod(10, 'Qatar', 'Qatar'),
    PrayerMethod(11, 'MUIS', 'Majlis Ugama Islam Singapura, Singapore'),
    PrayerMethod(12, 'UOIF', 'Union Organization Islamic de France'),
    PrayerMethod(13, 'Diyanet', 'Diyanet İşleri Başkanlığı, Turkey'),
    PrayerMethod(14, 'Russia', 'Spiritual Administration of Muslims of Russia'),
    PrayerMethod(15, 'Moonsighting', 'Moonsighting Committee Worldwide'),
    PrayerMethod(16, 'Dubai', 'Dubai'),
    PrayerMethod(17, 'JAKIM', 'Jabatan Kemajuan Islam Malaysia (JAKIM)'),
    PrayerMethod(18, 'Tunisia', 'Tunisia'),
    PrayerMethod(19, 'Algeria', 'Algeria'),
    PrayerMethod(20, 'Kemenag', 'Kementerian Agama Republik Indonesia'),
    PrayerMethod(21, 'Morocco', 'Morocco'),
    PrayerMethod(22, 'Lisbon', 'Comunidade Islamica de Lisboa'),
    PrayerMethod(23, 'Jordan', 'Ministry of Awqaf, Jordan'),
  ];

  /// Countries without an entry use [muslimWorldLeague].
  static const Map<String, int> _methodByCountry = {
    'ID': kemenag,
    'MY': 17,
    'SG': 11,
    'SA': 4,
    'AE': 16,
    'QA': 10,
    'KW': 9,
    'TR': 13,
    'EG': 5,
    'IR': 7,
    'PK': 1,
    'IN': 1,
    'BD': 1,
    'AF': 1,
    'US': 2,
    'CA': 2,
    'FR': 12,
    'RU': 14,
    'TN': 18,
    'DZ': 19,
    'MA': 21,
    'PT': 22,
    'JO': 23,
  };

  static const Set<String> _hanafiCountries = {'PK', 'IN', 'BD', 'AF'};

  /// Kemenag adds an ihtiyat (safety margin) that Aladhan leaves out.
  /// Measured against Kemenag's schedule for cities in WIB, WITA and WIT,
  /// so prayers never start earlier and Sunrise never ends later than
  /// Kemenag's. Order: Imsak,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Sunset,Isha,
  /// Midnight.
  static const String _kemenagTune = '2,3,-4,4,4,4,0,3,0';

  /// An unknown country (never located) falls back to Indonesia.
  static int methodFor(String? countryCode) {
    if (countryCode == null) return kemenag;
    return _methodByCountry[countryCode] ?? muslimWorldLeague;
  }

  static int schoolFor(String? countryCode) =>
      _hanafiCountries.contains(countryCode) ? schoolHanafi : schoolShafi;

  static String? tuneFor(int method) => method == kemenag ? _kemenagTune : null;

  static PrayerMethod methodOf(int id) => methods.firstWhere(
    (method) => method.id == id,
    orElse: () => methodOf(muslimWorldLeague),
  );
}
