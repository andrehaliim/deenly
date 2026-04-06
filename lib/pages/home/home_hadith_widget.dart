import 'package:deenly/models/hadith_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeHadithWidget extends StatefulWidget {
  final HadithModel hadithModel;
  const HomeHadithWidget({super.key, required this.hadithModel});

  @override
  State<HomeHadithWidget> createState() => _HomeHadithWidgetState();
}

class _HomeHadithWidgetState extends State<HomeHadithWidget> {

  @override
  Widget build(BuildContext context) {
    return dailyHadith();
  }

  Widget dailyHadith() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondaryContainer,
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
          Text(
            widget.hadithModel.hadithEnglish,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.hadithModel.englishNarrator,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget dailyHadithSkeleton(BuildContext context) {
    final baseColor = const Color(0xFFE6D5B8);
    final highlightColor = const Color(0xFFF3E7D3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor.withValues(alpha: 0.6),
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
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
