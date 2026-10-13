import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// App name and tagline that slide up one after another.
class SplashTextWidget extends StatelessWidget {
  final Animation<double> animation;

  const SplashTextWidget({super.key, required this.animation});

  static const _slideBegin = Offset(0, 0.4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Primary teal is too dark on the dark surface, so use gold there.
    final titleColor = isDark ? colorScheme.secondary : colorScheme.primary;

    const titleInterval = Interval(0.35, 0.75, curve: Curves.easeOutCubic);
    const taglineInterval = Interval(0.5, 0.9, curve: Curves.easeOutCubic);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: animation.drive(CurveTween(curve: titleInterval)),
          child: SlideTransition(
            position: animation.drive(
              Tween(
                begin: _slideBegin,
                end: Offset.zero,
              ).chain(CurveTween(curve: titleInterval)),
            ),
            child: Text(
              l10n?.appTitle ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: animation.drive(CurveTween(curve: taglineInterval)),
          child: SlideTransition(
            position: animation.drive(
              Tween(
                begin: _slideBegin,
                end: Offset.zero,
              ).chain(CurveTween(curve: taglineInterval)),
            ),
            child: Text(
              l10n?.splashTagline ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
