import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';

class NotificationConfig {
  static final FlutterLocalNotificationsPlugin fln =
  FlutterLocalNotificationsPlugin();

  static const String androidChannelId = 'high_importance_channel';
  static const String androidChannelName = 'General';

  static Future<void> initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await fln.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();

    final box = await Hive.openBox('settings');
    final current = box.get('unreadNotification', defaultValue: 0) as int;
    await box.put('unreadNotification', current + 1);
  }
}
