import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints a Rub el Hizb style star made of two overlapping squares.
class EightPointStarPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool filled;

  const EightPointStarPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.filled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8 - math.pi / 2;
      final r = i.isEven ? radius : radius * 0.76;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EightPointStarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.filled != filled;
  }
}
