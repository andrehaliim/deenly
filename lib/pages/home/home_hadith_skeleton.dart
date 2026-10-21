import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeHadithSkeleton extends StatelessWidget {
  const HomeHadithSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Shimmer.fromColors(
        baseColor: baseColor.withValues(alpha: 0.15),
        highlightColor: baseColor.withValues(alpha: 0.35),
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
            SizedBox(height: 12),
            _Line(width: double.infinity),
            SizedBox(height: 8),
            _Line(width: 200),
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
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
