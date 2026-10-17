import 'package:deenly/pages/quran/eight_point_star_painter.dart';
import 'package:deenly/pages/quran/pressable_card_widget.dart';
import 'package:deenly/pages/quran/surah_number_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SurahCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final String arabicName;
  final bool isMakkiyah;
  final VoidCallback onTap;

  const SurahCard({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.arabicName,
    required this.isMakkiyah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final metaColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.8);
    final metaStyle = theme.textTheme.bodySmall?.copyWith(color: metaColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: PressableCard(
        onTap: onTap,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surfaceContainerLow,
              Color.alphaBlend(
                colorScheme.primary.withValues(alpha: 0.06),
                colorScheme.surfaceContainerLow,
              ),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
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
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -28,
              child: CustomPaint(
                size: const Size.square(110),
                painter: EightPointStarPainter(
                  color: colorScheme.primary.withValues(alpha: 0.06),
                  strokeWidth: 6,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
              child: Row(
                children: [
                  SurahNumberBadge(number: number),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            FaIcon(
                              isMakkiyah
                                  ? FontAwesomeIcons.kaaba
                                  : FontAwesomeIcons.mosque,
                              size: theme.textTheme.bodySmall?.fontSize,
                              color: colorScheme.secondary,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: metaColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: metaStyle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    arabicName,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.notoNaskhArabic(
                      textStyle: theme.textTheme.titleLarge,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
