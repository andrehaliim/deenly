import 'package:deenly/components/app_colors.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:deenly/pages/quran/eight_point_star_painter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SurahDetailHeader extends StatelessWidget {
  final SurahModel surah;
  final String langCode;

  const SurahDetailHeader({
    super.key,
    required this.surah,
    required this.langCode,
  });

  /// Al-Fatihah counts the basmala as its first ayah and At-Tawbah has none,
  /// so neither gets the separate basmala line.
  bool get _showBasmala => surah.id != 1 && surah.id != 9;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();
    final onCard = colorScheme.onPrimary;
    final l10n = AppLocalizations.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 24),
            child: Transform.scale(scale: 0.96 + value * 0.04, child: child),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: appColors?.heroGradient,
          boxShadow: [
            BoxShadow(
              color: appColors?.heroShadow ?? colorScheme.shadow,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: CustomPaint(
                size: const Size.square(180),
                painter: EightPointStarPainter(
                  color: onCard.withValues(alpha: 0.08),
                  strokeWidth: 10,
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: CustomPaint(
                size: const Size.square(130),
                painter: EightPointStarPainter(
                  color: onCard.withValues(alpha: 0.06),
                  strokeWidth: 8,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                children: [
                  Text(
                    surah.nameArab,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.notoNaskhArabic(
                      textStyle: theme.textTheme.headlineLarge,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondaryFixedDim,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.name(langCode),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onCard,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.desc(langCode),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onCard.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: onCard.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          surah.surahFrom == 1
                              ? FontAwesomeIcons.kaaba
                              : FontAwesomeIcons.mosque,
                          size: 12,
                          color: colorScheme.secondaryFixedDim,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${surah.surahTotal} ${l10n?.ayah ?? ''}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onCard,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showBasmala) ...[
                    const SizedBox(height: 20),
                    _OrnamentDivider(color: onCard.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'بِسْمِ ٱللّٰهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.notoNaskhArabic(
                        textStyle: theme.textTheme.headlineSmall,
                        fontWeight: FontWeight.bold,
                        color: onCard,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrnamentDivider extends StatelessWidget {
  final Color color;

  const _OrnamentDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Divider(color: color, height: 1));

    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomPaint(
            size: const Size.square(14),
            painter: EightPointStarPainter(color: color, filled: true),
          ),
        ),
        line,
      ],
    );
  }
}
