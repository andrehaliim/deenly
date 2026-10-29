import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/dzikir_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One dzikir as a tappable card: title, remaining count, Arabic text,
/// transliteration, translation and its virtue. Each tap counts one
/// recitation and a long press starts its count over; a finished card is
/// dimmed.
class DzikirItem extends StatelessWidget {
  final DzikirModel dzikir;
  final int number;
  final int remaining;
  final bool isActive;
  final String languageCode;
  final VoidCallback onTap;
  final VoidCallback onReset;

  const DzikirItem({
    super.key,
    required this.dzikir,
    required this.number,
    required this.remaining,
    required this.isActive,
    required this.languageCode,
    required this.onTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDone = remaining == 0;
    final note = dzikir.note(languageCode);
    final translation = dzikir.translation(languageCode);
    final borderRadius = BorderRadius.circular(20);

    return AnimatedOpacity(
      opacity: isDone ? 0.5 : 1,
      duration: const Duration(milliseconds: 250),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: isActive
                ? colorScheme.primary.withValues(alpha: 0.6)
                : colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: isActive ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isDone ? null : onTap,
          onLongPress: remaining < dzikir.count ? onReset : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
                        dzikir.name(languageCode),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CountBadge(remaining: remaining),
                  ],
                ),
                if (note != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  dzikir.textArab,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoNaskhArabic(
                    textStyle: theme.textTheme.titleLarge,
                    height: 2,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                if (dzikir.textLatin.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    dzikir.textLatin,
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
                const SizedBox(height: 14),
                _VirtueBox(
                  virtue: dzikir.virtue(languageCode),
                  source: dzikir.source,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows how many recitations are left, or a check once the item is done.
class _CountBadge extends StatelessWidget {
  final int remaining;

  const _CountBadge({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDone = remaining == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? colorScheme.primary : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: isDone
          ? Icon(Icons.check_rounded, size: 18, color: colorScheme.onPrimary)
          : Text(
              l10n?.dzikirTimes(remaining) ?? '',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
    );
  }
}

class _VirtueBox extends StatelessWidget {
  final String? virtue;
  final String source;

  const _VirtueBox({required this.virtue, required this.source});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final virtue = this.virtue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (virtue != null) ...[
            Text(
              l10n?.dzikirVirtue ?? '',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              virtue,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            source,
            style: theme.textTheme.labelSmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
