
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpriteAnimation {
  final List<ui.Image> frames;

  SpriteAnimation(this.frames);

  int currentFrame = 0;
  double elapsed = 0;

  static Future<SpriteAnimation> load(
      String animationName,
      int frameCount,
      ) async {
    final images = <ui.Image>[];

    for (int i = 0; i < frameCount; i++) {
      final data = await rootBundle.load(
        'assets/images/baby_hero_frames/'
            '${animationName}_$i.png',
      );

      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );

      final frame = await codec.getNextFrame();
      images.add(frame.image);
      codec.dispose();
    }

    return SpriteAnimation(images);
  }

  void update(double deltaTime) {
    if (frames.length < 2) return;

    elapsed += deltaTime;
    const frameDuration = 0.12;

    while (elapsed >= frameDuration) {
      elapsed -= frameDuration;
      currentFrame = (currentFrame + 1) % frames.length;
    }
  }

  ui.Image? get image {
    if (frames.isEmpty) return null;
    return frames[currentFrame];
  }

  void paint(Canvas canvas, Rect destination) {
    final currentImage = image;
    if (currentImage == null) return;

    canvas.drawImageRect(
      currentImage,
      Rect.fromLTWH(
        0,
        0,
        currentImage.width.toDouble(),
        currentImage.height.toDouble(),
      ),
      destination,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  void reset() {
    currentFrame = 0;
    elapsed = 0;
  }

  void dispose() {
    for (final frame in frames) {
      frame.dispose();
    }
  }
}
