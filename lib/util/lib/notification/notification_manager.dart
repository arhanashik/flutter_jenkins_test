import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Created by mdhasnain on 20 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. Building local notification
/// 2. Singleton pattern for notification manager
/// 3. Clearing notification if necessary

class NotificationManager {
  NotificationManager._();
  static final _instance = NotificationManager._();
  factory NotificationManager() => _instance;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  init() async {
    if(_initialized) return;
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification
    );

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS
    );
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: _selectNotification
    );
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload
  ) async {
    debugPrint(
        'local notification:(onDidReceiveLocalNotification) '
        'title: $title,'
        'body: $body,'
        'payload: $payload'
    );
  }

  Future _selectNotification(String payload) async {
    debugPrint('local notification: $payload');
  }

  notify({
    int id: 0,
    String channelId: 'def_id',
    String channelName: 'def_channel',
    String channelDescription: 'default channel',
    String title,
    String message,
    String payload,
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId, channelName, channelDescription,
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.show(
        id, title, message, platformChannelSpecifics, payload: payload
    );
  }

  clear({int id: -1}) async {
    id == -1
        ? await flutterLocalNotificationsPlugin.cancelAll()
        : await flutterLocalNotificationsPlugin.cancel(id);
  }
}