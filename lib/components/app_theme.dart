import 'package:deenly/components/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text styles that fall outside the Material [TextTheme] roles.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle brandTitle;
  final TextStyle counter;

  const AppTextStyles({required this.brandTitle, required this.counter});

  @override
  AppTextStyles copyWith({TextStyle? brandTitle, TextStyle? counter}) {
    return AppTextStyles(
      brandTitle: brandTitle ?? this.brandTitle,
      counter: counter ?? this.counter,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;

    return AppTextStyles(
      brandTitle: TextStyle.lerp(brandTitle, other.brandTitle, t) ?? brandTitle,
      counter: TextStyle.lerp(counter, other.counter, t) ?? counter,
    );
  }
}

/// ========================================
/// 🎨 APP THEME
/// ========================================
class AppTheme {
  static AppTextStyles _brandTextStyles(Color color) {
    return AppTextStyles(
      brandTitle: GoogleFonts.notoSerif(
        color: color,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ),
      counter: GoogleFonts.manrope(fontSize: 80, fontWeight: FontWeight.bold),
    );
  }

  /// ---------- LIGHT COLORS ----------
  static const _lightPrimary = Color(0xFF004D40);
  static const _lightSecondary = Color(0xFFC5A059);
  static const _lightTertiary = Color(0xFFE6D5B8);
  static const _lightNeutral = Color(0xFFF7F8F7);

  static const _lightSurface = _lightNeutral;
  static const _lightSurfaceLow = Color(0xFFEDEFED);
  static const _lightSurfaceLowest = Color(0xFFFFFFFF);
  static const _lightSurfaceHighest = Color(0xFFE1E4E1);

  static const _lightSurfaceContainer = Color(0xFFE9EBE9);
  static const _lightSurfaceHigh = Color(0xFFE5E8E5);
  static const _lightSurfaceDim = Color(0xFFD8DBD8);

  static const _lightOnSurface = Color(0xFF191C1B);
  static const _lightOnSurfaceVariant = Color(0xFF3F4946);
  static const _lightOutline = Color(0xFF707974);
  static const _lightOutlineVariant = Color(0xFFBFC9C4);
  static const _lightError = Color(0xFFBA1A1A);

  /// ---------- FIXED COLORS (same in light and dark) ----------
  static const _primaryFixed = Color(0xFFE0F2F1);
  static const _primaryFixedDim = Color(0xFF80CBC4);
  static const _onPrimaryFixed = Color(0xFF00201B);
  static const _secondaryFixed = Color(0xFFFFE7B8);
  static const _secondaryFixedDim = Color(0xFFD4B16A);
  static const _tertiaryFixed = Color(0xFFE6D5B8);
  static const _tertiaryFixedDim = Color(0xFFCDBDA0);
  static const _onAccentFixed = Color(0xFF261900);
  static const _onAccentFixedVariant = Color(0xFF4D4639);

  /// ---------- DARK COLORS ----------
  static const _darkPrimary = Color(0xFF00756A);
  static const _darkSecondary = Color(0xFFD4B16A);
  static const _darkTertiary = Color(0xFF4D4639);

  static const _darkSurface = Color(0xFF0E1111);
  static const _darkSurfaceLow = Color(0xFF161918);
  static const _darkSurfaceLowest = Color(0xFF0A0C0C);
  static const _darkSurfaceHighest = Color(0xFF222524);

  static const _darkSurfaceContainer = Color(0xFF1A1D1C);
  static const _darkSurfaceHigh = Color(0xFF1E2120);
  static const _darkSurfaceBright = Color(0xFF343736);

  static const _darkOnSurface = Color(0xFFE1E3E1);
  static const _darkOnSurfaceVariant = Color(0xFFBFC9C4);
  static const _darkOutline = Color(0xFF89938E);
  static const _darkOutlineVariant = Color(0xFF3F4946);
  static const _darkError = Color(0xFFFFB4AB);

  /// Deep teal for the large home card; [_darkPrimary] is too bright to
  /// fill that much of a dark screen.
  static const _darkHeroStart = Color(0xFF0F3B35);
  static const _darkHeroEnd = Color(0xFF0A2A26);

  static final _lightColors = AppColors(
    heroStart: _lightPrimary,
    heroEnd: Color.alphaBlend(
      _lightSecondary.withValues(alpha: 0.35),
      _lightPrimary,
    ),
    heroShadow: _lightPrimary.withValues(alpha: 0.3),
    menuSheet: _lightSurfaceLowest,
    menuTile: _primaryFixed,
    onMenuTile: _lightPrimary,
    navSelected: _lightPrimary,
    onNavSelected: const Color(0xFFE8E8E8),
  );

  static final _darkColors = AppColors(
    heroStart: _darkHeroStart,
    heroEnd: Color.alphaBlend(
      _darkSecondary.withValues(alpha: 0.12),
      _darkHeroEnd,
    ),
    heroShadow: Colors.black.withValues(alpha: 0.4),
    menuSheet: Colors.black.withValues(alpha: 0.28),
    menuTile: _primaryFixedDim.withValues(alpha: 0.16),
    onMenuTile: _primaryFixedDim,
    navSelected: const Color(0xFF14524A),
    onNavSelected: _primaryFixed,
  );

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
      tertiaryContainer: Color(0xFFF3EADB),
      onTertiaryContainer: Color(0xFF261900),
      primaryFixed: _primaryFixed,
      primaryFixedDim: _primaryFixedDim,
      onPrimaryFixed: _onPrimaryFixed,
      onPrimaryFixedVariant: _lightPrimary,
      secondaryFixed: _secondaryFixed,
      secondaryFixedDim: _secondaryFixedDim,
      onSecondaryFixed: _onAccentFixed,
      onSecondaryFixedVariant: _onAccentFixedVariant,
      tertiaryFixed: _tertiaryFixed,
      tertiaryFixedDim: _tertiaryFixedDim,
      onTertiaryFixed: _onAccentFixed,
      onTertiaryFixedVariant: _onAccentFixedVariant,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      surfaceDim: _lightSurfaceDim,
      surfaceBright: _lightSurface,
      surfaceContainerLowest: _lightSurfaceLowest,
      surfaceContainerLow: _lightSurfaceLow,
      surfaceContainer: _lightSurfaceContainer,
      surfaceContainerHigh: _lightSurfaceHigh,
      surfaceContainerHighest: _lightSurfaceHighest,
      error: _lightError,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      outline: _lightOutline,
      outlineVariant: _lightOutlineVariant,
      onSurfaceVariant: _lightOnSurfaceVariant,
      inverseSurface: Color(0xFF2E3130),
      onInverseSurface: Color(0xFFEFF1EF),
      inversePrimary: _primaryFixedDim,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: _lightPrimary,
    ),

    scaffoldBackgroundColor: _lightSurface,

    extensions: [_brandTextStyles(_lightPrimary), _lightColors],

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
      onPrimary: Color(0xFFE8E8E8),
      primaryContainer: Color(0xFF005046),
      onPrimaryContainer: Colors.white,
      secondary: _darkSecondary,
      onSecondary: Colors.black,
      secondaryContainer: _darkTertiary,
      onSecondaryContainer: Color(0xFFFFE7B8),
      tertiary: _darkTertiary,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF3A342A),
      onTertiaryContainer: Color(0xFFF3EADB),
      primaryFixed: _primaryFixed,
      primaryFixedDim: _primaryFixedDim,
      onPrimaryFixed: _onPrimaryFixed,
      onPrimaryFixedVariant: _lightPrimary,
      secondaryFixed: _secondaryFixed,
      secondaryFixedDim: _secondaryFixedDim,
      onSecondaryFixed: _onAccentFixed,
      onSecondaryFixedVariant: _onAccentFixedVariant,
      tertiaryFixed: _tertiaryFixed,
      tertiaryFixedDim: _tertiaryFixedDim,
      onTertiaryFixed: _onAccentFixed,
      onTertiaryFixedVariant: _onAccentFixedVariant,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceDim: _darkSurface,
      surfaceBright: _darkSurfaceBright,
      surfaceContainerLowest: _darkSurfaceLowest,
      surfaceContainerLow: _darkSurfaceLow,
      surfaceContainer: _darkSurfaceContainer,
      surfaceContainerHigh: _darkSurfaceHigh,
      surfaceContainerHighest: _darkSurfaceHighest,
      error: _darkError,
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
      onSurfaceVariant: _darkOnSurfaceVariant,
      inverseSurface: _darkOnSurface,
      onInverseSurface: Color(0xFF2E3130),
      inversePrimary: _lightPrimary,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: _darkPrimary,
    ),

    scaffoldBackgroundColor: _darkSurface,

    extensions: [_brandTextStyles(_primaryFixedDim), _darkColors],

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
