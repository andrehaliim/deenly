import 'package:flutter/material.dart';

/// App logo that pops in with a scale and fade during the splash intro.
class SplashLogoWidget extends StatelessWidget {
  final Animation<double> animation;

  const SplashLogoWidget({super.key, required this.animation});

  /// The image is the adaptive icon foreground, whose glyph fills only the
  /// middle ~55% of the canvas, so it is drawn larger than the visible logo.
  static const double _size = 220;

  @override
  Widget build(BuildContext context) {
    final opacity = animation.drive(
      CurveTween(curve: const Interval(0, 0.45, curve: Curves.easeOut)),
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
        child: Image.asset(
          'assets/images/splash_logo.png',
          width: _size,
          height: _size,
        ),
      ),
    );
  }
}
