import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/dzikir_period_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// Takes turns with the hadith at the bottom of the home overview card
/// while a dzikir window is open, leading straight to that dzikir.
class HomeDzikirReminder extends StatelessWidget {
  final DzikirPeriod period;
  final String endTime;
  final VoidCallback onStart;

  /// Whether the parent gives this a bounded height to fill; the verse
  /// then shows as many lines as fit in it.
  final bool fillsHeight;

  const HomeDzikirReminder({
    super.key,
    required this.period,
    required this.endTime,
    required this.onStart,
    required this.fillsHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onCard = colorScheme.onPrimary;
    final accent = colorScheme.secondaryFixedDim;
    final l10n = AppLocalizations.of(context);

    final title = switch (period) {
      DzikirPeriod.morning => l10n?.dzikirReminderMorning,
      DzikirPeriod.evening => l10n?.dzikirReminderEvening,
    };
    final icon = switch (period) {
      DzikirPeriod.morning => FontAwesomeIcons.sun,
      DzikirPeriod.evening => FontAwesomeIcons.moon,
    };

    /// Sits on the prayer gradient at the bottom of the home overview card.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onCard,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: onCard.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(icon, size: 16, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n?.dzikirReminderUntil(endTime) ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: onCard.withValues(alpha: 0.75),
            ),
          ),
          Flexible(
            flex: fillsHeight ? 1 : 0,
            child: _FittedVerse(
              verse: TextSpan(
                children: [
                  TextSpan(text: l10n?.dzikirReminderVerse ?? ''),
                  TextSpan(
                    text: ' ${l10n?.dzikirReminderVerseSource ?? ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
              style: GoogleFonts.notoSerif(
                textStyle: theme.textTheme.bodyMedium,
                color: onCard.withValues(alpha: 0.92),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: colorScheme.onSecondaryFixed,
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n?.dzikirReminderStart ?? ''),
          ),
        ],
      ),
    );
  }
}

/// The verse, cut to as many lines as fit when the height is bounded and
/// left out when not even one does, so the card never overflows.
class _FittedVerse extends StatelessWidget {
  static const double _topGap = 8;

  final InlineSpan verse;
  final TextStyle style;

  const _FittedVerse({required this.verse, required this.style});

  double _lineHeight(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: ' ', style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final height = painter.height;
    painter.dispose();
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int? maxLines;
        if (constraints.hasBoundedHeight) {
          final lines =
              (constraints.maxHeight - _topGap) ~/ _lineHeight(context);
          if (lines < 1) return const SizedBox.shrink();
          maxLines = lines;
        }

        return Padding(
          padding: const EdgeInsets.only(top: _topGap),
          child: Text.rich(
            verse,
            style: style,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
