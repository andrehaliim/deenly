import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeHadithSkeleton extends StatefulWidget {
  const HomeHadithSkeleton({super.key});

  @override
  State<HomeHadithSkeleton> createState() => _HomeHadithSkeletonState();
}

class _HomeHadithSkeletonState extends State<HomeHadithSkeleton> {
  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onPrimary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
            Theme.of(context).colorScheme.primary,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor.withValues(alpha: 0.5),
        highlightColor: baseColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Daily Hadith',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 16),

            // Hadith lines
            _line(width: double.infinity),
            const SizedBox(height: 8),
            _line(width: double.infinity),
            const SizedBox(height: 8),
            _line(width: double.infinity),
            const SizedBox(height: 8),
            _line(width: 200),

            const SizedBox(height: 16),

            // Narrator
            _line(width: 180),
          ],
        ),
      ),
    );
  }

  Widget _line({required double width}) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
