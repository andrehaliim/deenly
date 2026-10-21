import 'dart:math' as math;

import 'package:deenly/models/asmaul_husna_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AsmaulHusnaCard extends StatelessWidget {
  final AsmaulHusnaModel name;
  final String meaning;

  const AsmaulHusnaCard({super.key, required this.name, required this.meaning});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: colorScheme.secondary),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _NumberBadge(number: name.id),
                ),
                const SizedBox(height: 4),
                Text(
                  name.textArab,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoNaskhArabic(
                    textStyle: theme.textTheme.headlineSmall,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const _OrnamentDivider(),
                const SizedBox(height: 8),
                Text(
                  name.textLatin,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meaning,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A gold diamond inside a thin diamond outline, echoing the divider
/// ornament. The number itself stays upright.
class _NumberBadge extends StatelessWidget {
  final int number;

  const _NumberBadge({required this.number});

  static const double _size = 34;
  static const double _innerSize = 22;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox.square(
      dimension: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: _innerSize + 6,
              height: _innerSize + 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: _innerSize,
              height: _innerSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.secondaryFixedDim,
                    colorScheme.secondary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _innerSize * 0.8,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                number.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    final line = Container(
      width: 20,
      height: 1.5,
      color: color.withValues(alpha: 0.6),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        line,
        const SizedBox(width: 6),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(width: 6, height: 6, color: color),
        ),
        const SizedBox(width: 6),
        line,
      ],
    );
  }
}
