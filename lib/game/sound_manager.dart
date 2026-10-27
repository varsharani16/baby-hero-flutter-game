
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class SoundManager {
  final AudioPlayer _jumpPlayer = AudioPlayer();
  final AudioPlayer _chocolatePlayer = AudioPlayer();

  Future<void> playJump() async {
    try {
      await _jumpPlayer.stop();
      await _jumpPlayer.play(
        AssetSource('sounds/jump.wav'),
      );
    }catch(e){
      debugPrint('Jump sound error: $e');
    }
  }

  Future<void> playChocolate() async {
    try {
      await _chocolatePlayer.stop();
      await _chocolatePlayer.play(
        AssetSource('sounds/chocolate.wav'),
      );
    }
    catch(e){
      debugPrint('Chocolate sound error: $e');
    }
  }

  Future<void> dispose() async {
    await _jumpPlayer.dispose();
    await _chocolatePlayer.dispose();
  }
}
