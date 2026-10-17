import 'dart:async';

import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Draggable thumb on the trailing edge of the ayah list. It appears while
/// the list scrolls, and dragging it jumps through ayahs with a label bubble.
/// Place it inside a [Stack] with [Positioned.fill].
class AyahFastScroller extends StatefulWidget {
  final int totalAyahs;
  final ValueListenable<int> currentAyah;
  final ValueChanged<int> onAyahSelected;

  const AyahFastScroller({
    super.key,
    required this.totalAyahs,
    required this.currentAyah,
    required this.onAyahSelected,
  });

  @override
  State<AyahFastScroller> createState() => _AyahFastScrollerState();
}

class _AyahFastScrollerState extends State<AyahFastScroller> {
  static const double _thumbWidth = 28;
  static const double _thumbHeight = 52;
  static const double _touchWidth = 48;
  static const double _verticalPadding = 8;
  static const Duration _hideDelay = Duration(milliseconds: 1500);

  bool _visible = false;
  bool _dragging = false;
  double _dragFraction = 0;
  int _dragAyah = 1;
  double _travelExtent = 1;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.currentAyah.addListener(_onScrolled);
  }

  @override
  void didUpdateWidget(covariant AyahFastScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentAyah != widget.currentAyah) {
      oldWidget.currentAyah.removeListener(_onScrolled);
      widget.currentAyah.addListener(_onScrolled);
    }
  }

  @override
  void dispose() {
    widget.currentAyah.removeListener(_onScrolled);
    _hideTimer?.cancel();
    super.dispose();
  }

  double _fractionOf(int ayah) {
    if (widget.totalAyahs <= 1) return 0;
    return ((ayah - 1) / (widget.totalAyahs - 1)).clamp(0.0, 1.0);
  }

  int _ayahOf(double fraction) =>
      (fraction * (widget.totalAyahs - 1)).round() + 1;

  void _onScrolled() {
    if (_dragging) {
      setState(() {});
      return;
    }
    setState(() => _visible = true);
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDelay, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _onDragStart(DragStartDetails details) {
    _hideTimer?.cancel();
    setState(() {
      _dragging = true;
      _visible = true;
      _dragAyah = widget.currentAyah.value;
      _dragFraction = _fractionOf(_dragAyah);
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final fraction = (_dragFraction + details.delta.dy / _travelExtent).clamp(
      0.0,
      1.0,
    );
    final ayah = _ayahOf(fraction);
    setState(() => _dragFraction = fraction);
    if (ayah != _dragAyah) {
      _dragAyah = ayah;
      widget.onAyahSelected(ayah);
    }
  }

  void _onDragEnd() {
    setState(() => _dragging = false);
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackHeight = constraints.maxHeight - _verticalPadding * 2;
        _travelExtent = (trackHeight - _thumbHeight).clamp(
          1.0,
          double.infinity,
        );

        final fraction = _dragging
            ? _dragFraction
            : _fractionOf(widget.currentAyah.value);
        final thumbTop = _verticalPadding + fraction * _travelExtent;
        final isShown = _visible || _dragging;
        final labelAyah = _dragging ? _dragAyah : widget.currentAyah.value;

        /// Eases the thumb between ayahs on manual scroll, but follows the
        /// finger exactly while dragging.
        final moveDuration = _dragging
            ? Duration.zero
            : const Duration(milliseconds: 150);

        return IgnorePointer(
          ignoring: !isShown,
          child: AnimatedOpacity(
            opacity: isShown ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: moveDuration,
                  right: _touchWidth + 4,
                  top: thumbTop + _thumbHeight / 2 - 20,
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      l10n?.ayahCount('$labelAyah') ?? '$labelAyah',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: moveDuration,
                  right: 0,
                  top: thumbTop,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: _onDragStart,
                    onVerticalDragUpdate: _onDragUpdate,
                    onVerticalDragEnd: (_) => _onDragEnd(),
                    onVerticalDragCancel: _onDragEnd,
                    child: SizedBox(
                      width: _touchWidth,
                      height: _thumbHeight,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: _thumbWidth,
                          height: _thumbHeight,
                          decoration: BoxDecoration(
                            color: _dragging
                                ? colorScheme.primary
                                : colorScheme.primary.withValues(alpha: 0.85),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(14),
                            ),
                          ),
                          child: Icon(
                            Icons.unfold_more_rounded,
                            size: 18,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
