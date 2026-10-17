import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fades and slides [child] in, delayed by its [index] within a shared
/// [animation]. Items past the first few share the last delay so a long
/// list does not wait for off-screen items.
class StaggeredEntrance extends StatefulWidget {
  final Animation<double> animation;
  final int index;
  final Offset slideFrom;
  final Widget child;

  const StaggeredEntrance({
    super.key,
    required this.animation,
    required this.index,
    required this.child,
    this.slideFrom = const Offset(0, 0.25),
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  static const _maxStaggered = 8;
  static const _step = 0.06;
  static const _span = 0.45;

  late CurvedAnimation _curve;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didUpdateWidget(StaggeredEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.index != widget.index ||
        oldWidget.slideFrom != widget.slideFrom) {
      _curve.dispose();
      _setupAnimations();
    }
  }

  void _setupAnimations() {
    final start = math.min(widget.index, _maxStaggered) * _step;
    _curve = CurvedAnimation(
      parent: widget.animation,
      curve: Interval(
        start,
        math.min(start + _span, 1),
        curve: Curves.easeOutCubic,
      ),
    );
    _slide = Tween<Offset>(
      begin: widget.slideFrom,
      end: Offset.zero,
    ).animate(_curve);
  }

  @override
  void dispose() {
    _curve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
