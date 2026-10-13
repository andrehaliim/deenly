import 'package:flutter/material.dart';

/// Slim progress bar that fades in at the end of the splash intro and
/// smoothly fills up as the startup steps complete.
class SplashLoaderWidget extends StatelessWidget {
  final Animation<double> animation;
  final double progress;

  const SplashLoaderWidget({
    super.key,
    required this.animation,
    required this.progress,
  });

  /// How long the bar takes to animate to a new [progress] value.
  static const fillDuration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: animation.drive(
        CurveTween(curve: const Interval(0.7, 1, curve: Curves.easeOut)),
      ),
      child: SizedBox(
        width: 96,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: fillDuration,
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
              color: colorScheme.secondary,
              backgroundColor: colorScheme.secondary.withValues(alpha: 0.2),
            );
          },
        ),
      ),
    );
  }
}
