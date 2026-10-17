import 'package:deenly/pages/quran/eight_point_star_painter.dart';
import 'package:flutter/material.dart';

class SurahNumberBadge extends StatelessWidget {
  final int number;
  final double size;

  const SurahNumberBadge({super.key, required this.number, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: EightPointStarPainter(
          color: colorScheme.primary.withValues(alpha: 0.1),
          filled: true,
        ),
        foregroundPainter: EightPointStarPainter(
          color: colorScheme.primary.withValues(alpha: 0.7),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
