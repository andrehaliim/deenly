import 'package:deenly/components/app_theme.dart';
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

    const titleInterval = Interval(0.05, 0.55, curve: Curves.easeOutCubic);
    const taglineInterval = Interval(0.3, 0.8, curve: Curves.easeOutCubic);

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
            // Same serif wordmark as the app bar, scaled up for the splash.
            child: Text(
              l10n?.appTitle ?? '',
              textAlign: TextAlign.center,
              style: theme.extension<AppTextStyles>()?.brandTitle.copyWith(
                color: titleColor,
                fontSize: 48,
                height: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
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
              (l10n?.splashTagline ?? '').toUpperCase(),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
