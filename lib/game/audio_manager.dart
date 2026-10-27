
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound(String fileName) async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource('sounds/$fileName'),
      );
    } catch (e) {
      // Sound failure should not crash the game.
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
