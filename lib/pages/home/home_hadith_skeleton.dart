import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeHadithSkeleton extends StatelessWidget {
  const HomeHadithSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHigh,
        highlightColor: colorScheme.surfaceContainerLowest,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Line(width: 120, height: 18),
                Spacer(),
                _Line(width: 28, height: 28),
              ],
            ),
            SizedBox(height: 8),
            _Line(width: 160),
            SizedBox(height: 16),
            _Line(width: double.infinity),
            SizedBox(height: 8),
            _Line(width: double.infinity),
            SizedBox(height: 8),
            _Line(width: double.infinity),
            SizedBox(height: 8),
            _Line(width: 200),
            SizedBox(height: 16),
            _Line(width: double.infinity, height: 44),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final double width;
  final double height;

  const _Line({required this.width, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
