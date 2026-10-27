
import 'package:flutter/material.dart';

class HealthPowerUp {
  HealthPowerUp({
    required this.x,
    required this.y,
    this.size = 30,
  });

  final double x;
  final double y;
  final double size;

  bool collected = false;

  Rect get rect => Rect.fromLTWH(x, y, size, size);



  void paint(Canvas canvas) {
    if (collected) return;

    final heartPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF5A70),
          Color(0xFFD50032),
        ],
      ).createShader(
        Rect.fromLTWH(x, y, size, size),
      )
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final heartPath = Path()
      ..moveTo(x + size * 0.5, y + size * 0.92)
      ..cubicTo(
        x + size * 0.42, y + size * 0.84,
        x + size * 0.04, y + size * 0.57,
        x + size * 0.04, y + size * 0.32,
      )
      ..cubicTo(
        x + size * 0.04, y + size * 0.08,
        x + size * 0.34, y + size * 0.02,
        x + size * 0.5, y + size * 0.25,
      )
      ..cubicTo(
        x + size * 0.66, y + size * 0.02,
        x + size * 0.96, y + size * 0.08,
        x + size * 0.96, y + size * 0.32,
      )
      ..cubicTo(
        x + size * 0.96, y + size * 0.57,
        x + size * 0.58, y + size * 0.84,
        x + size * 0.5, y + size * 0.92,
      )
      ..close();

    canvas.drawPath(heartPath, heartPaint);
  }


}
