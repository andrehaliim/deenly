import 'dart:math' as math;

import 'package:deenly/components/locale_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/hadith_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeHadithWidget extends StatefulWidget {
  final HadithModel hadithModel;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  /// Whether the parent gives this a bounded height to fill while
  /// collapsed; the text then shows as many lines as fit in it.
  final bool fillsHeight;

  const HomeHadithWidget({
    super.key,
    required this.hadithModel,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.fillsHeight,
  });

  @override
  State<HomeHadithWidget> createState() => _HomeHadithWidgetState();
}

class _HomeHadithWidgetState extends State<HomeHadithWidget> {
  /// Lines shown while collapsed when there is no height to fill.
  static const int _unboundedCollapsedLines = 3;

  late final TapGestureRecognizer _toggleRecognizer = TapGestureRecognizer()
    ..onTap = widget.onToggleExpanded;

  @override
  void initState() {
    super.initState();

    /// Line heights measured with a fallback font are off, so lay out
    /// again once Noto Serif has loaded.
    GoogleFonts.pendingFonts().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(HomeHadithWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _toggleRecognizer.onTap = widget.onToggleExpanded;
  }

  @override
  void dispose() {
    _toggleRecognizer.dispose();
    super.dispose();
  }

  /// Lines to show while collapsed: as many as fit in [constraints], or
  /// [_unboundedCollapsedLines] when its height is unbounded. `null` means
  /// the whole text fits.
  int? _collapsedLinesFor(
    String text,
    TextStyle style,
    BoxConstraints constraints,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: constraints.maxWidth);
    final totalLines = painter.computeLineMetrics().length;
    final height = painter.height;
    painter.dispose();
    if (totalLines == 0) return null;

    final fitLines = constraints.hasBoundedHeight
        ? math.max(1, (constraints.maxHeight / (height / totalLines)).floor())
        : _unboundedCollapsedLines;
    return fitLines >= totalLines ? null : fitLines;
  }

  /// Returns the longest prefix of [text] that, followed by an ellipsis
  /// and [suffix], still fits within [maxLines] lines of [maxWidth].
  String _truncateToFit({
    required String text,
    required TextStyle style,
    required InlineSpan suffix,
    required int maxLines,
    required double maxWidth,
  }) {
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: maxLines,
    );

    bool fits(int length) {
      painter
        ..text = TextSpan(
          style: style,
          children: [
            TextSpan(text: '${text.substring(0, length).trimRight()}… '),
            suffix,
          ],
        )
        ..layout(maxWidth: maxWidth);
      return !painter.didExceedMaxLines;
    }

    var low = 0;
    var high = text.length;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      if (fits(mid)) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    painter.dispose();

    return '${text.substring(0, low).trimRight()}… ';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onCard = colorScheme.onPrimary;
    final accent = colorScheme.secondaryFixedDim;
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();

    final text = localeProvider.locale?.languageCode == 'id'
        ? widget.hadithModel.hadithIndonesian
        : widget.hadithModel.hadithEnglish;
    final textStyle = DefaultTextStyle.of(context).style.merge(
      GoogleFonts.notoSerif(
        textStyle: theme.textTheme.bodyMedium,
        color: onCard.withValues(alpha: 0.92),
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
    );
    final isExpanded = widget.isExpanded;

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
                  l10n?.hadithTitle ?? '',
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
                child: Icon(Icons.menu_book_rounded, size: 16, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: l10n?.hadithNarrated ?? ''),
                TextSpan(
                  text: widget.hadithModel.englishNarrator
                      .replaceAll('Narrated', '')
                      .replaceAll(':', '')
                      .trim(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: onCard.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            flex: widget.fillsHeight ? 1 : 0,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final collapsedLines = _collapsedLinesFor(
                    text,
                    textStyle,
                    constraints,
                  );
                  final toggleSpan = TextSpan(
                    text: isExpanded
                        ? l10n?.showLess ?? ''
                        : l10n?.showMore ?? '',
                    style: textStyle.copyWith(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                    ),
                    recognizer: _toggleRecognizer,
                  );

                  final String visibleText;
                  if (collapsedLines == null) {
                    visibleText = text;
                  } else if (isExpanded) {
                    visibleText = '$text ';
                  } else {
                    visibleText = _truncateToFit(
                      text: text,
                      style: textStyle,
                      suffix: toggleSpan,
                      maxLines: collapsedLines,
                      maxWidth: constraints.maxWidth,
                    );
                  }

                  return Text.rich(
                    TextSpan(
                      style: textStyle,
                      children: [
                        TextSpan(text: visibleText),
                        if (collapsedLines != null) toggleSpan,
                      ],
                    ),
                    maxLines: isExpanded ? null : collapsedLines,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
