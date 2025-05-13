import 'dart:convert';

import 'package:get/get.dart';
import '../../domain/repositories/i_notification_repository.dart';

class NotificationController extends GetxController {
  final INotificationRepository _repository;

  NotificationController(this._repository);

  final Rx<String?> deviceToken = Rx<String?>(null);
  final RxBool isNotificationPermissionGranted = false.obs;
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> backgroundNotifications = <Map<String, dynamic>>[].obs;
  final RxList<Map<String?, Object?>> tappedNotifications = <Map<String?, Object?>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _repository.initialize();
    await _requestPermissions();

    deviceToken.value = await _repository.getDeviceToken();

    await _repository.configure(
      onForeground: _handleForegroundMessage,
      onBackground: _handleBackgroundMessage,
      onTap: _handleNotificationTap,
    );

    _repository.onTokenRefresh((newToken) {
      deviceToken.value = newToken;
    });
  }

  Future<void> _requestPermissions() async {
    await _repository.requestPermission();
    isNotificationPermissionGranted.value = true;
  }

  void _handleForegroundMessage(Map<String, dynamic> message) {
    if (message.isEmpty || message['notification'] == null) {
      return;
    }

    final String notificationTitle = message['notification']['title'] ?? 'Nueva notificación';
    final String notificationBody = message['notification']['body'] ?? 'Has recibido una nueva notificación';
    final Map<String, dynamic> notificationData = {};
    if (message.containsKey('data') && message['data'] is Map) {
      notificationData.addAll(Map<String, dynamic>.from(message['data']));
    }

    _repository.showForegroundNotification(
      notificationTitle,
      notificationBody,
      notificationData,
    );
  }


  void _handleBackgroundMessage(Map<String, dynamic> message) {
    if (message.isEmpty || message['notification'] == null) return;

    backgroundNotifications.add(message);
  }

  void _handleNotificationTap(Map<String?, Object?> message) {

    tappedNotifications.add(message);

    if (message.containsKey('payload') && message['payload'] is String) {
      try {
        final Map<String, dynamic> data = jsonDecode(message['payload'] as String);

        if (data['ruta'] == 'login') {
          Get.toNamed('/forgot-password');
        } else if (data['screen'] == 'profile') {
          Get.toNamed('/profile');
        }
      } catch (e) {
        print('⚠️ Error al decodificar el payload: $e');
      }
    }
  }

}
