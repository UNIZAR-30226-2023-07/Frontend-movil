import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final _BGMPlayer = AudioPlayer();

  static final _SFXPlayer = AudioPlayer();

  static Future<void> toggleBGM(bool value) async {
    if (value) {
      _BGMPlayer.setReleaseMode(ReleaseMode.LOOP);
      final player = AudioCache(prefix: 'music/');
      final url = await player.load('musiquita.mp3');
      await _BGMPlayer.play(url.path, isLocal: true);
    } else {
      await _BGMPlayer.release();
    }
  }

  static Future<void> setBGMVolume(double value) async {
    await _BGMPlayer.setVolume(value);
  }

  static Future<void> toggleSFX(bool value) async {
    if (value) {
      _SFXPlayer.setReleaseMode(ReleaseMode.LOOP);
      final player = AudioCache(prefix: 'music/');
      final url = await player.load('musiquita.mp3');
      await _SFXPlayer.play(url.path, isLocal: true);
    } else {
      await _SFXPlayer.release();
    }
  }

  static Future<void> setSFXVolume(double value) async {
    await _SFXPlayer.setVolume(value);
  }
}
