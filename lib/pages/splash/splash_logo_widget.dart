import 'package:flutter/material.dart';

/// App logo that pops in with a scale and fade during the splash intro.
class SplashLogoWidget extends StatelessWidget {
  final Animation<double> animation;

  const SplashLogoWidget({super.key, required this.animation});

  static const double _size = 120;
  static const double _radius = 32;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final opacity = animation.drive(
      CurveTween(curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    final scale = animation.drive(
      Tween<double>(begin: 0.6, end: 1).chain(
        CurveTween(curve: const Interval(0, 0.6, curve: Curves.easeOutBack)),
      ),
    );

    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(
        scale: scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: _size,
              height: _size,
            ),
          ),
        ),
      ),
    );
  }
}
