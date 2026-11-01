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
    final textColor = colorScheme.onPrimary;

    const titleInterval = Interval(0.25, 0.7, curve: Curves.easeOutCubic);
    const taglineInterval = Interval(0.45, 0.85, curve: Curves.easeOutCubic);

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
                color: textColor,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TaglineRule(color: colorScheme.secondary),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    (l10n?.splashTagline ?? '').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _TaglineRule(color: colorScheme.secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Short gold line that frames the tagline on both sides.
class _TaglineRule extends StatelessWidget {
  final Color color;

  const _TaglineRule({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 20, height: 1, color: color.withValues(alpha: 0.7));
  }
}
