import 'package:flutter/material.dart';

/// Card with an ink ripple that also shrinks slightly while pressed.
class PressableCard extends StatefulWidget {
  final VoidCallback onTap;
  final BoxDecoration decoration;
  final BorderRadius borderRadius;
  final Widget child;

  const PressableCard({
    super.key,
    required this.onTap,
    required this.decoration,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: widget.decoration.copyWith(
          borderRadius: widget.borderRadius,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: widget.borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
