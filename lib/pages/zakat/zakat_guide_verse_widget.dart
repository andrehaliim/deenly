import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/zakat_guide_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A Quran verse in the same Arabic style as the doa pages, with its
/// translation and reference below it.
class ZakatGuideVerse extends StatelessWidget {
  final ZakatGuideVerseModel verse;
  final String languageCode;

  const ZakatGuideVerse({
    super.key,
    required this.verse,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            verse.textArab,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoNaskhArabic(
              textStyle: theme.textTheme.titleLarge,
              height: 2,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${verse.translation.of(languageCode)}"',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.zakatVerseReference(
                  verse.surahName.of(languageCode),
                  verse.surah,
                  verse.ayah,
                ) ??
                '',
            textAlign: TextAlign.end,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
