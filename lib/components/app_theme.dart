import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ========================================
/// 🎨 CUSTOM COLOR EXTENSION (IMPORTANT)
/// ========================================
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color surfaceLow;
  final Color surfaceLowest;
  final Color surfaceHighest;

  const AppColors({
    required this.surfaceLow,
    required this.surfaceLowest,
    required this.surfaceHighest,
  });

  @override
  AppColors copyWith({
    Color? surfaceLow,
    Color? surfaceLowest,
    Color? surfaceHighest,
  }) {
    return AppColors(
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceLowest: surfaceLowest ?? this.surfaceLowest,
      surfaceHighest: surfaceHighest ?? this.surfaceHighest,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceLowest: Color.lerp(surfaceLowest, other.surfaceLowest, t)!,
      surfaceHighest: Color.lerp(surfaceHighest, other.surfaceHighest, t)!,
    );
  }
}

/// ========================================
/// 🎨 APP THEME
/// ========================================
class AppTheme {
  /// ---------- LIGHT COLORS ----------
  static const _lightPrimary = Color(0xFF004D40);
  static const _lightSecondary = Color(0xFFC5A059);
  static const _lightTertiary = Color(0xFFE6D5B8);
  static const _lightNeutral = Color(0xFFF7F8F7);

  static const _lightSurface = _lightNeutral;
  static const _lightSurfaceLow = Color(0xFFEDEFED);
  static const _lightSurfaceLowest = Color(0xFFFFFFFF);
  static const _lightSurfaceHighest = Color(0xFFE1E4E1);

  static const _lightOnSurface = Color(0xFF191C1B);
  static const _lightOnSurfaceVariant = Color(0xFF3F4946);
  static const _lightOutline = Color(0xFF707974);

  /// ---------- DARK COLORS ----------
  static const _darkPrimary = Color(0xFF80CBC4);
  static const _darkSecondary = Color(0xFFD4B16A);
  static const _darkTertiary = Color(0xFF4D4639);

  static const _darkSurface = Color(0xFF0E1111);
  static const _darkSurfaceLow = Color(0xFF161918);
  static const _darkSurfaceLowest = Color(0xFF0A0C0C);
  static const _darkSurfaceHighest = Color(0xFF222524);

  static const _darkOnSurface = Color(0xFFE1E3E1);
  static const _darkOnSurfaceVariant = Color(0xFFBFC9C4);
  static const _darkOutline = Color(0xFF89938E);

  /// ========================================
  /// 🌞 LIGHT THEME
  /// ========================================
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: GoogleFonts.manropeTextTheme(),

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: Color(0xFFE8E8E8),
      primaryContainer: Color(0xFFE0F2F1),
      onPrimaryContainer: _lightPrimary,
      secondary: _lightSecondary,
      onSecondary: Colors.white,
      secondaryContainer: _lightTertiary,
      onSecondaryContainer: Color(0xFF261900),
      tertiary: _lightTertiary,
      onTertiary: Color(0xFF261900),
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      error: Colors.red,
      onError: Colors.white,
      outline: _lightOutline,
      onSurfaceVariant: _lightOnSurfaceVariant,
    ),

    scaffoldBackgroundColor: _lightSurface,

    /// Extensions (YOUR DESIGN TOKENS)
    extensions: const [
      AppColors(
        surfaceLow: _lightSurfaceLow,
        surfaceLowest: _lightSurfaceLowest,
        surfaceHighest: _lightSurfaceHighest,
      ),
    ],

    /// AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightSurface,
      elevation: 0,
      foregroundColor: _lightOnSurface,
    ),

    /// Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurfaceHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightPrimary, width: 2),
      ),
    ),

    /// Buttons
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  /// ========================================
  /// 🌙 DARK THEME
  /// ========================================
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.manropeTextTheme(),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF005046),
      onPrimaryContainer: Colors.white,
      secondary: _darkSecondary,
      onSecondary: Colors.black,
      secondaryContainer: _darkTertiary,
      onSecondaryContainer: Color(0xFFFFE7B8),
      tertiary: _darkTertiary,
      onTertiary: Colors.white,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      error: Colors.red,
      onError: Colors.white,
      outline: _darkOutline,
      onSurfaceVariant: _darkOnSurfaceVariant,
    ),

    scaffoldBackgroundColor: _darkSurface,

    extensions: const [
      AppColors(
        surfaceLow: _darkSurfaceLow,
        surfaceLowest: _darkSurfaceLowest,
        surfaceHighest: _darkSurfaceHighest,
      ),
    ],

    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      elevation: 0,
      foregroundColor: _darkOnSurface,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
