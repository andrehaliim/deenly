import 'package:flutter/material.dart';

/// Brand colors that fall outside the Material [ColorScheme] roles, so
/// light and dark mode can each pick tones that suit their background.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color heroStart;
  final Color heroEnd;
  final Color heroShadow;
  final Color menuSheet;
  final Color menuTile;
  final Color onMenuTile;
  final Color navSelected;
  final Color onNavSelected;

  const AppColors({
    required this.heroStart,
    required this.heroEnd,
    required this.heroShadow,
    required this.menuSheet,
    required this.menuTile,
    required this.onMenuTile,
    required this.navSelected,
    required this.onNavSelected,
  });

  /// Diagonal gradient shared by every hero card, ring and highlight.
  LinearGradient get heroGradient => LinearGradient(
    colors: [heroStart, heroEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  AppColors copyWith({
    Color? heroStart,
    Color? heroEnd,
    Color? heroShadow,
    Color? menuSheet,
    Color? menuTile,
    Color? onMenuTile,
    Color? navSelected,
    Color? onNavSelected,
  }) {
    return AppColors(
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      heroShadow: heroShadow ?? this.heroShadow,
      menuSheet: menuSheet ?? this.menuSheet,
      menuTile: menuTile ?? this.menuTile,
      onMenuTile: onMenuTile ?? this.onMenuTile,
      navSelected: navSelected ?? this.navSelected,
      onNavSelected: onNavSelected ?? this.onNavSelected,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;

    return AppColors(
      heroStart: mix(heroStart, other.heroStart),
      heroEnd: mix(heroEnd, other.heroEnd),
      heroShadow: mix(heroShadow, other.heroShadow),
      menuSheet: mix(menuSheet, other.menuSheet),
      menuTile: mix(menuTile, other.menuTile),
      onMenuTile: mix(onMenuTile, other.onMenuTile),
      navSelected: mix(navSelected, other.navSelected),
      onNavSelected: mix(onNavSelected, other.onNavSelected),
    );
  }
}
