
import 'package:flutter/material.dart';
import 'enemy_data.dart';
import 'game_data.dart';
import 'health_powerup.dart';
import 'sprite_animation.dart';
import 'collection_effect.dart';

class GamePainter extends CustomPainter {
  final double playerX;
  final double playerY;
  final double cameraX;
  final double groundY;
  final List<GamePlatform> platforms;
  final List<Chocolate> chocolates;
  final Set<int> collected;
  final SpriteAnimation? heroAnimation;
  final List<CollectionEffect> collectionEffects;
  final List<GameEnemy> enemies;
  final bool hideHero;
  final List<HealthPowerUp> healthPowerUps;
  final GameFinish finish;
  final bool facingLeft;

  GamePainter({
    required this.playerX,
    required this.playerY,
    required this.cameraX,
    required this.groundY,
    required this.platforms,
    required this.chocolates,
    required this.collected,
    required this.collectionEffects,
    required this.enemies,
    required this.healthPowerUps,
    required this.finish,
    required this.facingLeft,
    this.hideHero = false,
    this.heroAnimation,



  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF80D8FF),
    );

    // Clouds
    final cloudPaint = Paint()..color = Colors.white;

    for (int i = 0; i < 7; i++) {
      final x =
          (i * 180.0 - cameraX * 0.25) %
              (size.width + 160) -
              20;
      final y = 55.0 + (i % 3) * 35;

      canvas.drawCircle(Offset(x, y), 17, cloudPaint);
      canvas.drawCircle(Offset(x + 20, y - 8), 22, cloudPaint);
      canvas.drawCircle(Offset(x + 40, y), 16, cloudPaint);
    }

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width,
          size.height - groundY),
      Paint()..color = const Color(0xFF99603B),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, 9),
      Paint()..color = const Color(0xFF279447),
    );

    // Floating platforms
    for (final platform in platforms) {
      final x = platform.x - cameraX;

      if (x + platform.width < 0 || x > size.width) {
        continue;
      }

      final top = groundY - platform.height;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, platform.width, 18),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFF278D39),
      );

      canvas.drawRect(
        Rect.fromLTWH(x, top + 10, platform.width, 9),
        Paint()..color = const Color(0xFF86502D),
      );
    }



    // Finish flag
    final finishX = finish.x - cameraX;

    if (finishX > -finish.width &&
        finishX < size.width + finish.width) {
      final polePaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      final poleTop = groundY - finish.height;

      canvas.drawLine(
        Offset(finishX, poleTop),
        Offset(finishX, groundY),
        polePaint,
      );

      final flagPath = Path()
        ..moveTo(finishX, poleTop)
        ..lineTo(finishX + finish.width, poleTop + 10)
        ..lineTo(finishX, poleTop + 25)
        ..close();

      canvas.drawPath(
        flagPath,
        Paint()..color = const Color(0xFF00C853),
      );

      canvas.drawCircle(
        Offset(finishX, poleTop),
        5,
        Paint()..color = const Color(0xFFFFD54F),
      );
    }



    // Chocolates
    for (int i = 0; i < chocolates.length; i++) {
      if (collected.contains(i)) continue;

      final chocolate = chocolates[i];
      final x = chocolate.x - cameraX;
      final y = groundY - chocolate.height;

      if (x < -45 || x > size.width + 45) continue;

      drawChocolate(canvas, x, y);
    }



    // Health Power-Ups
    for (final heart in healthPowerUps) {
      if (heart.collected) continue;

      final screenX = heart.x - cameraX;
      final screenY = groundY - heart.size - 50;

      if (screenX < -45 || screenX > size.width + 45) {
        continue;
      }

      canvas.save();
      canvas.translate(screenX - heart.x, screenY - heart.y);
      heart.paint(canvas);
      canvas.restore();
    }


    // Threatening monster enemy
    for (final enemy in enemies) {
      final enemyRect = Rect.fromLTWH(
        enemy.x - cameraX,
        enemy.y,
        enemy.width,
        enemy.height,
      );

      final bodyPaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF5252),
            Color(0xFFB71C1C),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(enemyRect);

      final outlinePaint = Paint()
        ..color = const Color(0xFF4A0000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final spikePaint = Paint()
        ..color = const Color(0xFFFFCC80);

      final eyePaint = Paint()
        ..color = const Color(0xFFFFEB3B);

      final pupilPaint = Paint()
        ..color = const Color(0xFF160000);

      // Spikes on top of the monster
      for (int i = 0; i < 3; i++) {
        final spikeX = enemyRect.left + 8 + i * 12;
        final spike = Path()
          ..moveTo(spikeX, enemyRect.top + 9)
          ..lineTo(spikeX + 5, enemyRect.top - 5)
          ..lineTo(spikeX + 10, enemyRect.top + 9)
          ..close();

        canvas.drawPath(spike, spikePaint);
        canvas.drawPath(spike, outlinePaint);
      }

      // Monster body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          enemyRect,
          const Radius.circular(10),
        ),
        bodyPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          enemyRect,
          const Radius.circular(10),
        ),
        outlinePaint,
      );

      // Angry yellow eyes
      final leftEye = Offset(
        enemyRect.left + enemy.width * 0.32,
        enemyRect.top + enemy.height * 0.35,
      );
      final rightEye = Offset(
        enemyRect.left + enemy.width * 0.70,
        enemyRect.top + enemy.height * 0.35,
      );

      canvas.drawCircle(leftEye, 5, eyePaint);
      canvas.drawCircle(rightEye, 5, eyePaint);

      canvas.drawCircle(leftEye, 2.5, pupilPaint);
      canvas.drawCircle(rightEye, 2.5, pupilPaint);

      // Angry eyebrows
      final browPaint = Paint()
        ..color = const Color(0xFF300000)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(leftEye.dx - 5, leftEye.dy - 6),
        Offset(leftEye.dx + 4, leftEye.dy - 3),
        browPaint,
      );

      canvas.drawLine(
        Offset(rightEye.dx - 4, rightEye.dy - 3),
        Offset(rightEye.dx + 5, rightEye.dy - 6),
        browPaint,
      );

      // Evil mouth
      final mouthRect = Rect.fromCenter(
        center: Offset(
          enemyRect.center.dx,
          enemyRect.top + enemy.height * 0.72,
        ),
        width: enemy.width * 0.55,
        height: enemy.height * 0.23,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          mouthRect,
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF300000),
      );

      // Sharp teeth
      final toothPaint = Paint()
        ..color = Colors.white;

      for (int i = 0; i < 3; i++) {
        final toothX = mouthRect.left + 4 + i * 7;
        final tooth = Path()
          ..moveTo(toothX, mouthRect.top)
          ..lineTo(toothX + 4, mouthRect.top)
          ..lineTo(toothX + 2, mouthRect.top + 5)
          ..close();

        canvas.drawPath(tooth, toothPaint);
      }
    }



    //drawHero(canvas, playerX - cameraX, playerY);
    if (heroAnimation?.image != null) {
      if (!hideHero) {
        canvas.save();

        final heroRect = Rect.fromLTWH(
          playerX - cameraX - 8,
          playerY - 8,
          52,
          56,
        );

        if (facingLeft) {
          canvas.translate(
            heroRect.left + heroRect.width,
            heroRect.top,
          );
          canvas.scale(-1, 1);

          heroAnimation!.paint(
            canvas,
            Rect.fromLTWH(
              0,
              0,
              heroRect.width,
              heroRect.height,
            ),
          );
        } else {
          heroAnimation!.paint(canvas, heroRect);
        }

        canvas.restore();
      }
    } else {
      drawHero(canvas, playerX - cameraX, playerY);
    }

    // Chocolate collection sparkle effects
    for (final effect in collectionEffects) {
      canvas.save();
      canvas.translate(-cameraX, 0);
      effect.paint(canvas);
      canvas.restore();
    }

    //draw heart
    for (final heart in healthPowerUps) {
      if (!heart.collected) {
        heart.paint(canvas);
      }
    }
  }

  void drawChocolate(Canvas canvas, double x, double y) {
    final wrapper = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, 38, 29),
      const Radius.circular(5),
    );

    canvas.drawRRect(
      wrapper,
      Paint()..color = const Color(0xFF4B168C),
    );

    canvas.drawRRect(
      wrapper,
      Paint()
        ..color = const Color(0xFFFFD65A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final foldPaint = Paint()
      ..color = const Color(0xFFFFD65A)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(x + 4, y + 5),
      Offset(x + 9, y + 24),
      foldPaint,
    );

    canvas.drawLine(
      Offset(x + 34, y + 5),
      Offset(x + 29, y + 24),
      foldPaint,
    );

    final label = TextPainter(
      text: const TextSpan(
        text: 'Dairy\nMilk',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          height: 0.9,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 24);

    label.paint(canvas, Offset(x + 7, y + 4));
  }

  void drawHero(Canvas canvas, double x, double y) {
    // Red cape
    final cape = Path()
      ..moveTo(x + 10, y + 18)
      ..lineTo(x - 7, y + 39)
      ..lineTo(x + 17, y + 33)
      ..close();

    canvas.drawPath(
      cape,
      Paint()..color = const Color(0xFFE53935),
    );

    // Legs
    final legs = Paint()
      ..color = const Color(0xFF173FA8)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(x + 12, y + 38),
      Offset(x + 10, y + 46),
      legs,
    );

    canvas.drawLine(
      Offset(x + 25, y + 38),
      Offset(x + 27, y + 46),
      legs,
    );

    // Face
    canvas.drawCircle(
      Offset(x + 18, y + 15),
      15,
      Paint()..color = const Color(0xFFFFD0A0),
    );

    // Hair
    final hair = Paint()..color = const Color(0xFF54301F);
    canvas.drawCircle(Offset(x + 11, y + 4), 7, hair);
    canvas.drawCircle(Offset(x + 22, y + 4), 7, hair);

    // Eyes
    final eyes = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(x + 13, y + 15), 1.8, eyes);
    canvas.drawCircle(Offset(x + 23, y + 15), 1.8, eyes);

    // Smile
    final smile = Path()
      ..moveTo(x + 13, y + 22)
      ..quadraticBezierTo(x + 18, y + 27, x + 23, y + 22);

    canvas.drawPath(
      smile,
      Paint()
        ..color = Colors.brown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Blue superhero suit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 5, y + 28, 26, 13),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF1769FF),
    );

    final star = TextPainter(
      text: const TextSpan(
        text: '★',
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    star.paint(canvas, Offset(x + 12, y + 28));
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
