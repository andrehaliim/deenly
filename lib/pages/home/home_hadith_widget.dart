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
  const HomeHadithWidget({super.key, required this.hadithModel});

  @override
  State<HomeHadithWidget> createState() => _HomeHadithWidgetState();
}

class _HomeHadithWidgetState extends State<HomeHadithWidget> {
  /// Fewest hadith lines shown while collapsed, even on tiny screens.
  static const int _minCollapsedLines = 3;

  /// Space kept between the card and the bottom of the viewport.
  static const double _bottomSpacing = 12;

  final GlobalKey _textKey = GlobalKey();
  late final TapGestureRecognizer _toggleRecognizer = TapGestureRecognizer()
    ..onTap = _toggleExpanded;

  bool _isExpanded = false;

  /// Max lines while collapsed; `null` means the full text fits.
  int? _collapsedLines;
  String? _text;
  TextStyle? _textStyle;

  /// Adjusts [_collapsedLines] so the collapsed card ends above the
  /// bottom of the scroll viewport (i.e. above the bottom nav).
  void _fitToViewport() {
    if (!mounted || _isExpanded) return;

    final text = _text;
    final style = _textStyle;
    final scrollable = Scrollable.maybeOf(context);
    final cardBox = context.findRenderObject();
    final textBox = _textKey.currentContext?.findRenderObject();
    final viewportBox = scrollable?.context.findRenderObject();
    if (text == null ||
        style == null ||
        scrollable == null ||
        cardBox is! RenderBox ||
        textBox is! RenderBox ||
        viewportBox is! RenderBox ||
        !cardBox.hasSize ||
        !textBox.hasSize ||
        !viewportBox.hasSize) {
      return;
    }

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: textBox.size.width);
    final metrics = painter.computeLineMetrics();
    painter.dispose();
    if (metrics.isEmpty) return;

    final totalLines = metrics.length;
    final lineHeight = metrics.first.height;
    if (lineHeight <= 0) return;

    // Position inside the scroll content, independent of scroll offset.
    final cardTop =
        cardBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy +
        scrollable.position.pixels;
    final overflow =
        cardTop +
        cardBox.size.height +
        _bottomSpacing -
        viewportBox.size.height;

    final currentLines = _collapsedLines ?? totalLines;
    final lineDelta = overflow > 0
        ? -(overflow / lineHeight).ceil()
        : (-overflow / lineHeight).floor();
    final targetLines = math.max(_minCollapsedLines, currentLines + lineDelta);
    final newLines = targetLines >= totalLines ? null : targetLines;

    if (newLines != _collapsedLines) {
      setState(() => _collapsedLines = newLines);
    }
  }

  @override
  void dispose() {
    _toggleRecognizer.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
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
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();

    final text = localeProvider.locale?.languageCode == 'id'
        ? widget.hadithModel.hadithIndonesian
        : widget.hadithModel.hadithEnglish;
    if (text != _text) {
      _text = text;
      _collapsedLines = null;
    }

    final textStyle = DefaultTextStyle.of(context).style.merge(
      GoogleFonts.notoSerif(
        fontSize: theme.textTheme.bodyMedium?.fontSize,
        color: colorScheme.onPrimary,
        fontStyle: FontStyle.italic,
      ),
    );
    _textStyle = textStyle;

    final collapsedLines = _collapsedLines;

    if (!_isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToViewport());
    }

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              l10n?.hadithTitle ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final toggleSpan = TextSpan(
                text: _isExpanded ? l10n?.showLess ?? '' : l10n?.showMore ?? '',
                style: textStyle.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                ),
                recognizer: _toggleRecognizer,
              );

              final String visibleText;
              if (collapsedLines == null) {
                visibleText = text;
              } else if (_isExpanded) {
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
                key: _textKey,
                maxLines: _isExpanded ? null : collapsedLines,
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.hadithNarrated ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.hadithModel.englishNarrator
                      .replaceAll("Narrated", "")
                      .replaceAll(":", ""),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
