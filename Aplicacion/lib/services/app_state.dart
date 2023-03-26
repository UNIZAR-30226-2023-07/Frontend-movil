import 'package:flutter/material.dart';
//import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'audio_manager.dart';

class AppStateListener extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
      // La aplicación ha pasado de segundo plano a primer plano
        AudioManager.resumeBGM();
        //FlutterAppBadger.updateBadgeCount(1);
        break;
      case AppLifecycleState.paused:
      // La aplicación ha pasado de primer plano a segundo plano
        AudioManager.pauseBGM();
        //FlutterAppBadger.updateBadgeCount(1);
        break;
      default:
    }
  }
}