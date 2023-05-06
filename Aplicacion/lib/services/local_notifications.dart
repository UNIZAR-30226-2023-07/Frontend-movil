import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'local_storage.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _enabled = false;

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    if(LocalStorage.prefs.getBool('enabledNotifications') != null) {
      _enabled = LocalStorage.prefs.getBool('enabledNotifications') as bool;
    } else {
      _enabled = (await notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestPermission())!;
      LocalStorage.prefs.setBool('enabledNotifications', _enabled);
    }

    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('1', 'Recordatorio',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, notificationDetails());
  }

  Future<void> showDailyNotificationAtTime(
      {required int id,
        required String title,
        required String body,
        required int hour,
        required int minute}) async {
    var time = tz.TZDateTime.now(tz.local).add(Duration(
        hours: hour - tz.TZDateTime.now(tz.local).hour - 2,
        minutes: minute - tz.TZDateTime.now(tz.local).minute));
    await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        time,
        notificationDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time);
  }
}
