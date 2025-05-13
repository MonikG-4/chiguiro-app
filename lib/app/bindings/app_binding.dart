import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../core/network/graphql_client_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/cache_storage_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/graphql_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/sync_task_storage_service.dart';
import '../data/repositories/push_notification_repository.dart';
import '../domain/repositories/i_notification_repository.dart';
import '../presentation/controllers/notification_controller.dart';
import '../presentation/controllers/session_controller.dart';
import 'survey_binding.dart';

class AppBinding {
  Future<void> initAsyncDependencies(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await Get.putAsync<CacheStorageService>(() async => CacheStorageService(),
        permanent: true);
    await Get.putAsync<LocationService>(() async => LocationService(),
        permanent: true);
    await Get.putAsync<AudioService>(() async => AudioService(),
        permanent: true);

    final connectivityService = Get.put(ConnectivityService(), permanent: true);
    await connectivityService.waitForInitialization();
    Get.put(LocalStorageService(), permanent: true);
    Get.put(SyncTaskStorageService(), permanent: true);

    final cacheStorageService = Get.find<CacheStorageService>();
    Get.put(SessionController(cacheStorageService), permanent: true);
    SurveyBinding().dependencies();
    final syncService = Get.put(SyncService(), permanent: true);
    syncService.onInit();

    Get.put<GraphQLService>(
      GraphQLService(clientProvider: GraphQLClientProvider()),
      permanent: true,
    );

    // Notifications
    Get.put<INotificationRepository>(
        PushNotificationRepository(flutterLocalNotificationsPlugin),
        permanent: true);
    Get.put(NotificationController(Get.find<INotificationRepository>()),
        permanent: true);
  }
}
