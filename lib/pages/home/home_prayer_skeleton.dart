import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomePrayerSkeleton extends StatelessWidget {
  const HomePrayerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Shimmer.fromColors(
        baseColor: baseColor.withValues(alpha: 0.15),
        highlightColor: baseColor.withValues(alpha: 0.35),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: _Block(width: 140, height: 28),
            ),
            const SizedBox(height: 10),
            const _Block(width: 180, height: 14),
            const SizedBox(height: 6),
            const _Block(width: 140, height: 12),
            const SizedBox(height: 12),
            const _Block(width: 150, height: 48),
            const SizedBox(height: 10),
            const _Block(width: 200, height: 14),
            const SizedBox(height: 12),
            const _Block(width: double.infinity, height: 1),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                5,
                (_) => const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: _Block(width: double.infinity, height: 64),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double width;
  final double height;

  const _Block({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
