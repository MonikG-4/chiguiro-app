abstract class INotificationRepository {
  Future<void> initialize();
  Future<void> requestPermission();
  Future<String?> getDeviceToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<void> onTokenRefresh(Function(String) callback);
  Future<void> configure({
    Function(Map<String, dynamic>)? onForeground,
    Function(Map<String, dynamic>)? onBackground,
    Function(Map<String?, Object?>)? onTap,
  });
  Future<void> showForegroundNotification(String title, String body, Map<String, dynamic>? data);
}