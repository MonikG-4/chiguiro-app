import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push/push.dart';

import '../../domain/repositories/i_notification_repository.dart';

class PushNotificationRepository implements INotificationRepository {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notificaciones Importantes',
    description: 'Canal para notificaciones importantes',
    importance: Importance.max,
    playSound: true,
  );

  PushNotificationRepository(this._flutterLocalNotificationsPlugin);

  /// 🔹 **Inicializa el servicio de notificaciones**
  @override
  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/icon'),
    );

    await _notificationsPlugin.initialize(settings);

    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// 🔹 **Crea el canal de notificaciones en Android**
  Future<void> _createNotificationChannel() async {
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(_channel);
  }

  /// 🔹 **Solicita permisos de notificaciones en Android/iOS**
  @override
  Future<void> requestPermission() async {
    // 📌 iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // 📌 Android 13+
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final granted =
          await androidImplementation?.requestNotificationsPermission();
      debugPrint('🔔 Permiso de notificación en Android: $granted');
    }
  }

  /// 🔹 **Obtiene el token del dispositivo**
  @override
  Future<String?> getDeviceToken() => Push.instance.token;

  /// 🔹 **Maneja la suscripción/desuscripción a temas (no implementado)**
  @override
  Future<void> subscribeToTopic(String topic) async =>
      debugPrint('Subscribing to topic: $topic');

  @override
  Future<void> unsubscribeFromTopic(String topic) async =>
      debugPrint('Unsubscribing from topic: $topic');

  /// 🔹 **Maneja la actualización del token**
  @override
  Future<void> onTokenRefresh(Function(String) callback) async {
    Push.instance.addOnNewToken(callback);
  }

  /// 🔹 **Configura los eventos de notificaciones**
  @override
  Future<void> configure({
    Function(Map<String, dynamic>)? onForeground,
    Function(Map<String, dynamic>)? onBackground,
    Function(Map<String?, Object?>)? onTap,
  }) async {
    Push.instance.addOnMessage((message) {
      final data = _extractNotificationData(message);
      if (onForeground != null) onForeground(data);
    });

    Push.instance.addOnBackgroundMessage((message) {
      final data = _extractNotificationData(message);
      if (onBackground != null) onBackground(data);
    });

    Push.instance.addOnNotificationTap((data) {
      if (onTap != null) onTap(data);
    });

    Push.instance.notificationTapWhichLaunchedAppFromTerminated.then((data) {
      if (data != null && onTap != null) {
        debugPrint("🔄 Notificación abrió la app: $data");
        // Esperamos a que la app se inicialice completamente antes de ejecutar la acción
        Future.delayed(const Duration(seconds: 2), () {
          onTap(data);
        });
      }
    });
  }

  /// 🔹 **Extrae la información de la notificación recibida**
  Map<String, dynamic> _extractNotificationData(RemoteMessage message) {
    return {
      'notification': {
        'title': message.notification?.title ?? 'Sin título',
        'body': message.notification?.body ?? 'Sin cuerpo',
      },
      'data': message.data,
    };
  }

  /// 🔹 **Muestra una notificación local en primer plano**
  @override
  Future<void> showForegroundNotification(
      String title, String body, Map<String, dynamic>? data) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'Notificaciones',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final payload = data != null ? jsonEncode(data) : '';

    await _flutterLocalNotificationsPlugin.show(
        DateTime.now().second,
        title,
        body,
        platformChannelSpecifics,
        payload: payload);
  }
}
