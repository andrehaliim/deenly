import 'package:deenly/models/doa_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One doa as a plain list row: title, Arabic text, transliteration and
/// translation. The list adds the dividers between rows.
class DoaItem extends StatelessWidget {
  final DoaModel doa;
  final int number;
  final String languageCode;

  const DoaItem({
    super.key,
    required this.doa,
    required this.number,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final translation = doa.translation(languageCode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number.',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  doa.name(languageCode),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            doa.textArab,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoNaskhArabic(
              textStyle: theme.textTheme.titleLarge,
              height: 2,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          if (doa.textLatin.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              doa.textLatin,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: colorScheme.secondary,
              ),
            ),
          ],
          if (translation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              translation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
