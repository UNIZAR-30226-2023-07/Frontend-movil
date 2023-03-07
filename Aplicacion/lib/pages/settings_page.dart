import 'package:flutter/material.dart';
import '../themes/theme_manager.dart';
import '../services/local_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsPage> {

  final Icon _muted = const Icon(
    Icons.volume_off,
  );
  final Icon _nonMuted = const Icon(
    Icons.volume_up,
  );

  double _musicValue = 100;
  double _oldMusicValue = 100;
  bool _muteMusic = false;
  late Icon _musicIcon = _nonMuted;

  double _soundEffectsValue = 100;
  double _oldSoundEffectsValue = 100;
  bool _muteSoundEffects = false;
  late Icon _soundEffectsIcon = _nonMuted;

  void muteUnmuteMusic() {
    setState(() {
      _muteMusic = !_muteMusic;
      LocalStorage.prefs.setBool('muteMusic', _muteMusic);
      if (_muteMusic) {
        _oldMusicValue = _musicValue;
        _musicValue = 0;
        _musicIcon = _muted;
      } else {
        _musicValue = _oldMusicValue;
        _musicIcon = _nonMuted;
      }
    });
  }

  void muteUnmuteSoundEffects() {
    setState(() {
      _muteSoundEffects = !_muteSoundEffects;
      LocalStorage.prefs.setBool('muteSoundEffects', _muteSoundEffects);
      if (_muteSoundEffects) {
        _oldSoundEffectsValue = _soundEffectsValue;
        _soundEffectsValue = 0;
        _soundEffectsIcon = _muted;
      } else {
        _soundEffectsValue = _oldSoundEffectsValue;
        _soundEffectsIcon = _nonMuted;
      }
    });
  }


  @override
  void initState() {
    if(LocalStorage.prefs.getDouble('musicValue') != null) {
      _musicValue = LocalStorage.prefs.getDouble('musicValue') as double;
    }
    if(LocalStorage.prefs.getBool('muteMusic') != null) {
      _muteMusic = LocalStorage.prefs.getBool('muteMusic') as bool;
      if (_muteMusic) {
        _musicIcon = _muted;
      } else {
        _musicIcon = _nonMuted;
      }
    }
    if(LocalStorage.prefs.getDouble('oldMusicValue') != null) {
      _oldMusicValue = LocalStorage.prefs.getDouble('oldMusicValue') as double;
    }
    if(LocalStorage.prefs.getDouble('soundEffectsValue') != null) {
      _soundEffectsValue = LocalStorage.prefs.getDouble('soundEffectsValue') as double;
    }
    if(LocalStorage.prefs.getBool('muteSoundEffects') != null) {
      _muteSoundEffects = LocalStorage.prefs.getBool('muteSoundEffects') as bool;
      if (_muteSoundEffects) {
        _soundEffectsIcon = _muted;
      } else {
        _soundEffectsIcon = _nonMuted;
      }
    }
    if(LocalStorage.prefs.getDouble('oldSoundEffectsValue') != null) {
      _oldSoundEffectsValue = LocalStorage.prefs.getDouble('oldSoundEffectsValue') as double;
    }

    themeManager.addListener(themeListener);

    super.initState();
  }

  @override
  void dispose() {
    LocalStorage.prefs.setDouble('musicValue', _musicValue);
    LocalStorage.prefs.setDouble('oldMusicValue', _oldMusicValue);
    LocalStorage.prefs.setBool('muteMusic', _muteMusic);
    LocalStorage.prefs.setDouble('soundEffectsValue', _soundEffectsValue);
    LocalStorage.prefs.setDouble('oldSoundEffectsValue', _oldSoundEffectsValue);
    LocalStorage.prefs.setBool('muteSoundEffects', _muteSoundEffects);

    themeManager.addListener(themeListener);

    super.dispose();
  }

  themeListener() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text( 'Sonido', style: Theme.of(context).textTheme.headlineMedium),
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Música'),
                ),
                Expanded(
                  child: Slider.adaptive(
                    value: _musicValue,
                    max: 100,
                    divisions: 100,
                    label: _musicValue.round().toString(),
                    //activeColor: Colors.indigoAccent,
                    onChanged: (double value) {
                      if (_muteMusic) {
                        null;
                      } else {
                        setState(() {
                          _musicValue = value;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 30,
                  icon: _musicIcon,
                  onPressed: muteUnmuteMusic,
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Efectos de sonido'),
                ),
                Expanded(
                  child: Slider.adaptive(
                    value: _soundEffectsValue,
                    max: 100,
                    divisions: 100,
                    label: _soundEffectsValue.round().toString(),
                    //activeColor: Colors.indigoAccent,
                    onChanged: (double value) {
                      if (_muteSoundEffects) {
                        null;
                      } else {
                        setState(() {
                          _soundEffectsValue = value;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 30,
                  icon: _soundEffectsIcon,
                  onPressed: muteUnmuteSoundEffects,
                ),
              ],
            ),
            const SizedBox(height: 10,),
            const Divider(
              color: Colors.indigoAccent,
            ),
            const SizedBox(height: 10,),
            Text( 'Tema', style: Theme.of(context).textTheme.headlineMedium),
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Modo oscuro'),
                ),
                const Spacer(),
                Switch(
                  value: themeManager.darkMode,
                  onChanged: (bool value) {
                    themeManager.toggleTheme();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}