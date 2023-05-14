import 'package:flutter/material.dart';
import 'package:untitled/services/audio_manager.dart';
import 'package:untitled/services/open_dialog.dart';
import 'package:untitled/widgets/custom_filled_button.dart';
import '../dialogs/delete_account.dart';
import '../themes/theme_manager.dart';
import '../services/local_storage.dart';

class SettingsPage extends StatefulWidget {

  final String email;
  final String code;

  const SettingsPage({super.key, required this.email, required this.code});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsPage> {

  final int _animationsDuration = 200;

  final Icon _muted = const Icon(
    Icons.volume_off,
  );
  final Icon _nonMuted = const Icon(
    Icons.volume_up,
  );

  bool _musicOn = false;
  double _musicValue = 100;
  double _oldMusicValue = 100;
  bool _muteMusic = false;
  late Icon _musicIcon = _nonMuted;

  bool _soundEffectsOn = false;
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
        AudioManager.setBGMVolume(0);
      } else {
        _musicValue = _oldMusicValue;
        _musicIcon = _nonMuted;
        AudioManager.setBGMVolume(_musicValue / 100.0);
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
        AudioManager.setSFXVolume(0);
      } else {
        _soundEffectsValue = _oldSoundEffectsValue;
        _soundEffectsIcon = _nonMuted;
        AudioManager.setSFXVolume(_musicValue / 100.0);
      }
    });
  }


  @override
  void initState() {
    super.initState();

    if(LocalStorage.prefs.getBool('musicOn') != null) {
      _musicOn = LocalStorage.prefs.getBool('musicOn') as bool;
    }
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
    if(LocalStorage.prefs.getBool('soundEffectsOn') != null) {
      _soundEffectsOn = LocalStorage.prefs.getBool('soundEffectsOn') as bool;
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

  }

  @override
  void dispose() {
    LocalStorage.prefs.setBool('musicOn', _musicOn);
    LocalStorage.prefs.setDouble('musicValue', _musicValue);
    LocalStorage.prefs.setDouble('oldMusicValue', _oldMusicValue);
    LocalStorage.prefs.setBool('muteMusic', _muteMusic);
    LocalStorage.prefs.setBool('soundEffectsOn', _soundEffectsOn);
    LocalStorage.prefs.setDouble('soundEffectsValue', _soundEffectsValue);
    LocalStorage.prefs.setDouble('oldSoundEffectsValue', _oldSoundEffectsValue);
    LocalStorage.prefs.setBool('muteSoundEffects', _muteSoundEffects);

    themeManager.removeListener(themeListener);

    super.dispose();
  }

  themeListener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text( 'Sonido', style: Theme.of(context).textTheme.headlineMedium),
            Row(
              children: [
                const Text('Música'),
                const Spacer(),
                Switch.adaptive(
                  value: _musicOn,
                  onChanged: (bool value){
                    AudioManager.playBGM(value);
                    setState(() {
                      _musicOn = value;
                    });
                  }
                ),
              ],
            ),
            AnimatedContainer(
              curve: Curves.ease,
              duration: Duration(milliseconds: _animationsDuration),
              height: _musicOn ? 50 : 0,
              width: double.infinity,
              child: AnimatedOpacity(
                curve: Curves.ease,
                duration: Duration(milliseconds: _animationsDuration),
                opacity: _musicOn ? 1.0 : 0.0,
                child: _musicOn
                ? Row(
                  children: [
                    const SizedBox(
                      child: Text('Volumen'),
                    ),
                    Expanded(
                      child: Slider.adaptive(
                        value: _musicValue,
                        max: 100,
                        divisions: 100,
                        label: _musicValue.round().toString(),
                        onChanged: (double value) {
                          if (_muteMusic) {
                            null;
                          } else {
                            AudioManager.setBGMVolume(value / 100.0);
                            setState(() {
                              _musicValue = value;
                            });
                          }
                        },
                      ),
                    ),
                    Tooltip(
                        message: 'Silenciar música',
                        child: IconButton(
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 30,
                          icon: _musicIcon,
                          onPressed: muteUnmuteMusic,
                        )
                    )
                  ],
                )
                : null
              ),
            ),
            Row(
              children: [
                const Text('Efectos de sonido'),
                const Spacer(),
                Switch.adaptive(
                  value: _soundEffectsOn,
                  onChanged: (bool value){
                    AudioManager.playSFX(value);
                    setState(() {
                      _soundEffectsOn = value;
                    });
                  }
                ),
              ],
            ),
            AnimatedContainer(
              curve: Curves.ease,
              duration: Duration(milliseconds: _animationsDuration),
              height: _soundEffectsOn ? 50 : 0,
              width: double.infinity,
              child: AnimatedOpacity(
                curve: Curves.ease,
                duration: Duration(milliseconds: _animationsDuration),
                opacity: _soundEffectsOn ? 1.0 : 0.0,
                child: _soundEffectsOn
                ? Row(
                  children: [
                    const SizedBox(
                      child: Text('Volumen'),
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
                            AudioManager.setSFXVolume(value / 100.0);
                            setState(() {
                              _soundEffectsValue = value;
                            });
                          }
                        },
                      ),
                    ),
                    Tooltip(
                        message: 'Silenciar efectos de sonido',
                        child: IconButton(
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 30,
                          icon: _soundEffectsIcon,
                          onPressed: muteUnmuteSoundEffects,
                        )
                    ),
                  ],
                )
                : null
              )
            ),
            const SizedBox(height: 10,),
            const Divider(
              color: Colors.indigoAccent,
            ),
            const SizedBox(height: 10,),
            Text( 'Tema', style: Theme.of(context).textTheme.headlineMedium),
            Row(
              children: [
                const Text('Modo oscuro'),
                const Spacer(),
                Switch.adaptive(
                  value: themeManager.darkMode,
                  onChanged: (bool value) {
                    themeManager.toggleTheme();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10,),
            const Divider(
              color: Colors.indigoAccent,
            ),
            const SizedBox(height: 10,),
            Text( 'Cuenta', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10,),
            CustomFilledButton(
              onPressed: () async {
                openDialog(
                    context,
                    DeleteAccountDialog(code: widget.code)
                );
              },
              content: const Text('Borrar cuenta')
            )
          ],
        ),
      ),
    );
  }
}