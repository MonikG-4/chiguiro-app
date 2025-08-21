import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static final _fln = FlutterLocalNotificationsPlugin();
  static Function()? onNewNotification;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    await _initLocalNotifications();

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined || settings.authorizationStatus == AuthorizationStatus.denied) {
      await _requestNotificationPermissions();
    }

    _setupFCMListeners();
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _fln.initialize(const InitializationSettings(android: androidInit, iOS: iosInit));
  }

  Future<void> _requestNotificationPermissions() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _setupFCMListeners() {
    FirebaseMessaging.onMessage.listen(_showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigation);
    FirebaseMessaging.instance.getInitialMessage().then(_handleNavigation);
  }

  void _showNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    if (Platform.isAndroid) {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'General',
        importance: Importance.max,
        priority: Priority.high,
      );

      _fln.show(
        0,
        notification.title,
        notification.body,
        const NotificationDetails(android: androidDetails),
      );
    }
    onNewNotification?.call();
    _handleNavigation(message);
  }

  void _handleNavigation(RemoteMessage? message) {
    if (message?.data['route'] != null) {
      final route = message!.data['route']!;
      Get.toNamed(route);
    }
  }

  Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
