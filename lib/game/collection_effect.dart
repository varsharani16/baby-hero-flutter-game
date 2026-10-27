import 'dart:math' as math;
import 'package:flutter/material.dart';

class CollectionEffect {
  CollectionEffect({
    required this.position,
    this.duration = 0.65,
  }) : particles = List<CollectionParticle>.generate(
    10,
        (index) {
      final angle = (math.pi * 2 * index / 10);
      final speed = 28.0 + (index % 3) * 13.0;
      return CollectionParticle(
        angle: angle,
        speed: speed,
        size: 3.0 + (index % 3) * 1.5,
      );
    },
  );

  final Offset position;
  final double duration;
  final List<CollectionParticle> particles;
  double elapsed = 0;

  bool get isFinished => elapsed >= duration;

  void update(double dt) {
    elapsed = math.min(duration, elapsed + dt);
  }

  void paint(Canvas canvas) {
    final progress = (elapsed / duration).clamp(0.0, 1.0);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final paint = Paint()..style = PaintingStyle.fill;

    // Bright center flash
    paint.color = const Color(0xFFFFF176).withOpacity(opacity * 0.9);
    canvas.drawCircle(position, 5 + 10 * progress, paint);

    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = position.dx + math.cos(particle.angle) * distance;
      final y = position.dy + math.sin(particle.angle) * distance;
      final size = particle.size * (1.0 - progress * 0.55);

      paint.color = _colorFor(particle).withOpacity(opacity);
      _drawSparkle(canvas, Offset(x, y), size, paint);
    }
  }

  Color _colorFor(CollectionParticle particle) {
    final colors = <Color>[
      const Color(0xFFFFEB3B),
      const Color(0xFFFFC107),
      const Color(0xFFFFFFFF),
      const Color(0xFFFF80AB),
      const Color(0xFF80DEEA),
    ];
    return colors[particles.indexOf(particle) % colors.length];
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.28, center.dy - size * 0.28)
      ..lineTo(center.dx + size, center.dy)
      ..lineTo(center.dx + size * 0.28, center.dy + size * 0.28)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.28, center.dy + size * 0.28)
      ..lineTo(center.dx - size, center.dy)
      ..lineTo(center.dx - size * 0.28, center.dy - size * 0.28)
      ..close();
    canvas.drawPath(path, paint);
  }
}

class CollectionParticle {
  const CollectionParticle({
    required this.angle,
    required this.speed,
    required this.size,
  });

  final double angle;
  final double speed;
  final double size;
}
