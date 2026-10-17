import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/continue_model.dart';
import 'package:deenly/pages/quran/eight_point_star_painter.dart';
import 'package:deenly/pages/quran/pressable_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinueCard extends StatelessWidget {
  final ContinueModel data;
  final String langCode;
  final VoidCallback onTap;

  const ContinueCard({
    super.key,
    required this.data,
    required this.langCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final ayahNum = data.ayahNumber == 0 ? 1 : data.ayahNumber;
    final total = data.surah.surahTotal;
    final progress = total > 0 ? (ayahNum / total).clamp(0.0, 1.0) : 0.0;
    final onCard = colorScheme.onPrimary;

    return SizedBox(
      width: 230,
      child: PressableCard(
        onTap: onTap,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              Color.alphaBlend(
                colorScheme.secondary.withValues(alpha: 0.35),
                colorScheme.primary,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -36,
              bottom: -44,
              child: CustomPaint(
                size: const Size.square(140),
                painter: EightPointStarPainter(
                  color: onCard.withValues(alpha: 0.1),
                  strokeWidth: 8,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 16,
              child: Text(
                data.surah.nameArab,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.notoNaskhArabic(
                  textStyle: theme.textTheme.titleLarge,
                  fontWeight: FontWeight.w600,
                  color: onCard.withValues(alpha: 0.9),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: onCard.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.solidBookmark,
                      size: 12,
                      color: colorScheme.secondaryFixedDim,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    data.surah.name(langCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onCard,
                    ),
                  ),
                  if (l10n != null)
                    Text(
                      l10n.ayahCount('$ayahNum / $total'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: onCard.withValues(alpha: 0.8),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 4,
                          backgroundColor: onCard.withValues(alpha: 0.2),
                          color: colorScheme.secondaryFixedDim,
                        ),
                      );
                    },
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
