import 'package:deenly/components/app_theme.dart';
import 'package:deenly/models/reciter_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Page colors for the surah reader, independent of the app theme.
enum ReadingTheme {
  standard,
  dark,
  sepia;

  /// Theme for the reader; [standard] follows the app's light or dark mode.
  /// Always returns a raw [AppTheme] (never `Theme.of`, which MaterialApp has
  /// localized), so [AnimatedTheme] can interpolate between any two.
  ThemeData resolve(Brightness appBrightness) => switch (this) {
    ReadingTheme.standard =>
      appBrightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
    ReadingTheme.dark => AppTheme.dark,
    ReadingTheme.sepia => AppTheme.sepia,
  };
}

/// Reader preferences: text sizes, translation, reading theme, qari and
/// the intro clips played before ayah 1.
class QuranSettingsProvider extends ChangeNotifier {
  static const double minArabicSize = 20;
  static const double maxArabicSize = 44;
  static const double defaultArabicSize = 28;
  static const double minTranslationSize = 12;
  static const double maxTranslationSize = 22;
  static const double defaultTranslationSize = 14;

  static const _keyArabicSize = 'quranArabicSize';
  static const _keyTranslationSize = 'quranTranslationSize';
  static const _keyShowTranslation = 'quranShowTranslation';
  static const _keyReadingTheme = 'quranReadingTheme';
  static const _keyReciter = 'quranReciter';
  static const _keyPlayTaawudz = 'quranPlayTaawudz';
  static const _keyPlayBasmala = 'quranPlayBasmala';

  final SharedPreferences prefs;

  late double _arabicSize;
  double get arabicSize => _arabicSize;

  late double _translationSize;
  double get translationSize => _translationSize;

  late bool _showTranslation;
  bool get showTranslation => _showTranslation;

  late ReadingTheme _readingTheme;
  ReadingTheme get readingTheme => _readingTheme;

  late ReciterModel _reciter;
  ReciterModel get reciter => _reciter;

  late bool _playTaawudz;
  bool get playTaawudz => _playTaawudz;

  late bool _playBasmala;
  bool get playBasmala => _playBasmala;

  QuranSettingsProvider(this.prefs) {
    _arabicSize = prefs.getDouble(_keyArabicSize) ?? defaultArabicSize;
    _translationSize =
        prefs.getDouble(_keyTranslationSize) ?? defaultTranslationSize;
    _showTranslation = prefs.getBool(_keyShowTranslation) ?? true;
    final themeName = prefs.getString(_keyReadingTheme);
    _readingTheme = ReadingTheme.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => ReadingTheme.standard,
    );
    _reciter = ReciterModel.byId(prefs.getString(_keyReciter));
    _playTaawudz = prefs.getBool(_keyPlayTaawudz) ?? false;
    _playBasmala = prefs.getBool(_keyPlayBasmala) ?? true;
  }

  /// Values update in memory first, so sliders follow the finger without
  /// waiting on storage.
  Future<void> setArabicSize(double value) async {
    _arabicSize = value;
    notifyListeners();
    await prefs.setDouble(_keyArabicSize, value);
  }

  Future<void> setTranslationSize(double value) async {
    _translationSize = value;
    notifyListeners();
    await prefs.setDouble(_keyTranslationSize, value);
  }

  Future<void> setShowTranslation(bool value) async {
    _showTranslation = value;
    notifyListeners();
    await prefs.setBool(_keyShowTranslation, value);
  }

  Future<void> setReadingTheme(ReadingTheme value) async {
    _readingTheme = value;
    notifyListeners();
    await prefs.setString(_keyReadingTheme, value.name);
  }

  Future<void> setReciter(ReciterModel value) async {
    _reciter = value;
    notifyListeners();
    await prefs.setString(_keyReciter, value.id);
  }

  Future<void> setPlayTaawudz(bool value) async {
    _playTaawudz = value;
    notifyListeners();
    await prefs.setBool(_keyPlayTaawudz, value);
  }

  Future<void> setPlayBasmala(bool value) async {
    _playBasmala = value;
    notifyListeners();
    await prefs.setBool(_keyPlayBasmala, value);
  }
}
