import 'dart:async';

import 'package:flutter/material.dart';

/// Shows [children] one at a time, cross-fading to the next every
/// [interval], starting from the first. Swiping or tapping a dot below
/// switches by hand and restarts the wait. Holds the current one while
/// [isPaused].
class HomeRotatingFooter extends StatefulWidget {
  final List<Widget> children;
  final bool isPaused;
  final Duration interval;

  /// Whether the parent gives this a bounded height to fill.
  final bool fillsHeight;

  const HomeRotatingFooter({
    super.key,
    required this.children,
    required this.fillsHeight,
    this.isPaused = false,
    this.interval = const Duration(seconds: 8),
  });

  @override
  State<HomeRotatingFooter> createState() => _HomeRotatingFooterState();
}

class _HomeRotatingFooterState extends State<HomeRotatingFooter> {
  /// Slower flings count as a drag, not a swipe.
  static const double _minSwipeVelocity = 200;

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) {
      if (!widget.isPaused) _showAt(_index + 1);
    });
  }

  void _showAt(int index) {
    final count = widget.children.length;
    if (count < 2) return;
    setState(() => _index = index % count);
  }

  void _showByHand(int index) {
    _showAt(index);
    _startTimer();
  }

  void _onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _minSwipeVelocity) return;
    _showByHand(velocity < 0 ? _index + 1 : _index - 1);
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.children;
    if (children.isEmpty) return const SizedBox.shrink();
    final index = _index % children.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: widget.fillsHeight ? 1 : 0,
          fit: FlexFit.tight,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: _onSwipe,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              child: KeyedSubtree(key: ValueKey(index), child: children[index]),
            ),
          ),
        ),
        if (children.length > 1)
          _Dots(count: children.length, index: index, onTap: _showByHand),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  final ValueChanged<int> onTap;

  const _Dots({required this.count, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: i == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == index
                        ? colorScheme.secondaryFixedDim
                        : colorScheme.onPrimary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
