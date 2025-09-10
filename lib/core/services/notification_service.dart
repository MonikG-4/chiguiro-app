import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../configs/notification_config.dart';
import 'storage_service.dart';

class NotificationService extends GetxService with WidgetsBindingObserver {
  final StorageService _storage;

  NotificationService(this._storage);

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    final box = Hive.box('settings');
    if (!box.containsKey('unreadNotification')) {
      await box.put('unreadNotification', 0);
    }

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(
        NotificationConfig.firebaseMessagingBackgroundHandler);

    await NotificationConfig.initLocalNotifications();
    await _initPermissions();
    _setupFCMListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshUnread();
    }
  }

  Future<void> _initPermissions() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined ||
        settings.authorizationStatus == AuthorizationStatus.denied) {
      await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);
    }
  }

  void _setupFCMListeners() {
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigation);
    FirebaseMessaging.instance.getInitialMessage().then(_handleNavigation);
  }

  Future<void> _handleForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    if (Platform.isAndroid) {
      const androidDetails = AndroidNotificationDetails(
        NotificationConfig.androidChannelId,
        NotificationConfig.androidChannelName,
        channelDescription: 'General notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      await NotificationConfig.fln.show(
        message.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(android: androidDetails),
      );
    }

    await _incrementUnread();
    _handleNavigation(message);
  }

  void _handleNavigation(RemoteMessage? message) {
    final route = message?.data['route'];
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route);
    }
  }

  Future<void> _incrementUnread() async {
    final current = _storage.get<int>('unreadNotification', defaultValue: 0);
    await _storage.set<int>('unreadNotification', current + 1);
  }

  Future<void> refreshUnread() async {
    try {
      final personJson = _storage.get<Map>('accessPerson');
      final id = personJson['id']?.toString();
      if (id == null) return;
      // Simulate fetching unread count from server
    } catch (_) {}
  }

  Future<String?> getFCMToken() async =>
      FirebaseMessaging.instance.getToken();
}
