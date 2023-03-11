import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final audioPlayer = AudioPlayer();
  static double volumes = 1;

  static Future<void> toggleSFX(bool isPlaying) async {
    if (!isPlaying) {
      await audioPlayer.release();
    } else {
      audioPlayer.setReleaseMode(ReleaseMode.LOOP);
      final player = AudioCache(prefix: 'music/');
      final url = await player.load('musiquita.mp3');
      await audioPlayer.play(url.path, isLocal: true, volume: volumes);
    }
  }

  static void setVolume(double value) {
    volumes = value;
    audioPlayer.setVolume(value);
  }
}
