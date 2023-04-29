import 'package:audioplayers/audioplayers.dart';
import 'local_storage.dart';

class AudioManager {
  static AudioCache _BGMCache = AudioCache(prefix: 'music/');
  static AudioPlayer _BGMPlayer = AudioPlayer();
  static bool _BGMplay = false;
  static late Uri _url;

  static AudioCache _SFXCache = AudioCache(prefix: 'music/');
  static AudioPlayer _SFXPlayer = AudioPlayer();
  static bool _SFXPlay = false;

  static void startAudio() async {
    if(LocalStorage.prefs.getBool('musicOn') != null) {
      _BGMplay = LocalStorage.prefs.getBool('musicOn') as bool;
    }
    if(LocalStorage.prefs.getDouble('musicValue') != null) {
      double musicValue = LocalStorage.prefs.getDouble('musicValue') as double;
      _BGMPlayer.setVolume(musicValue);
    }
    if(LocalStorage.prefs.getBool('soundEffectsOn') != null) {
      _SFXPlay = LocalStorage.prefs.getBool('soundEffectsOn') as bool;
    }
    if(LocalStorage.prefs.getDouble('soundEffectsValue') != null) {
      double soundEffectsValue = LocalStorage.prefs.getDouble('soundEffectsValue') as double;
      _SFXPlayer.setVolume(soundEffectsValue);
    }
    await _BGMPlayer.setReleaseMode(ReleaseMode.LOOP);
    _url = await _BGMCache.load('musiquita2.mp3');
    await _SFXCache.load('sonido_carta.mp3');
  }

  static Future<void> playBGM(bool value) async {
    _BGMplay = value;
  }

  static Future<void> toggleBGM(bool value) async {
    if(_BGMplay) {
      if (value) {
        await _BGMPlayer.play(_url.path, isLocal: true);
      } else {
        await _BGMPlayer.release();
      }
    }
  }

  static Future<void> setBGMVolume(double value) async {
    await _BGMPlayer.setVolume(value);
  }

  static Future<void> resumeBGM() async {
    if (_BGMPlayer.state == PlayerState.PAUSED) {
      await _BGMPlayer.resume();
    }
  }

  static Future<void> pauseBGM() async {
    if (_BGMPlayer.state == PlayerState.PLAYING) {
      await _BGMPlayer.pause();
    }
  }

  static Future<void> playSFX(bool value) async {
    _SFXPlay = value;
  }

  static Future<void> toggleSFX(bool value) async {
    if (_SFXPlay) {
      if (value) {
        _SFXPlayer = await _SFXCache.play('sonido_carta.mp3');
      } else {
        await _SFXPlayer.release();
      }
    }
  }

  static Future<void> setSFXVolume(double value) async {
    await _SFXPlayer.setVolume(value);
  }

  static Future<void> resumeSFX() async {
    if (_SFXPlayer.state == PlayerState.PAUSED) {
      await _SFXPlayer.resume();
    }
  }

  static Future<void> pauseSFX() async {
    if (_SFXPlayer.state == PlayerState.PLAYING) {
      await _SFXPlayer.pause();
    }
  }
}
