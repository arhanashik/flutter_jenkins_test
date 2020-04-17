import 'package:firebase_messaging/firebase_messaging.dart';

/// Created by mdhasnain on 16 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class FcmManager {
  FcmManager._();
  factory FcmManager() => _instance;
  static final FcmManager _instance = FcmManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: true
          )
      );
      // Check the notification request result for iOS
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("FCM::(Settings registered) $settings");
      });

      // Configure the fcm events
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("FCM::(onMessage) $message");
          _fcmBackgroundMessageHandler(message);
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("FCM::(onLaunch) $message");
          _fcmBackgroundMessageHandler(message);
        },
        onResume: (Map<String, dynamic> message) async {
          print("FCM::(onResume) $message");
          _fcmBackgroundMessageHandler(message);
        },
      );

      // For testing purposes print the Firebase Messaging token
//      _firebaseMessaging.getToken().then((String token) {
//        print("FCM::(Push Messaging token) $token");
//        assert(token != null);
//        PrefUtil.save(PrefUtil.FCM_TOKEN, token);
//      });

      _initialized = true;
    }
  }

  Future<String> getFcmToken() async {
    String token = await _firebaseMessaging.getToken();
    print("FCM::(Push Messaging token) $token");
    return token;
  }

  Future<dynamic> _fcmBackgroundMessageHandler(Map<String, dynamic> message) {
    print('FCM:: $message');
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    return null;
  }
}