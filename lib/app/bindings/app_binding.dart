import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../core/network/graphql_client_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/cache_storage_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/graphql_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/revisit_storage_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/sync_task_storage_service.dart';
import '../data/repositories/push_notification_repository.dart';
import '../data/repositories/survey_repository.dart';
import '../domain/repositories/i_notification_repository.dart';
import '../domain/repositories/i_survey_repository.dart';
import '../presentation/controllers/notification_controller.dart';
import '../presentation/controllers/session_controller.dart';

class AppBinding {
  Future<void> initAsyncDependencies(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await Get.putAsync<CacheStorageService>(() async => CacheStorageService(),
        permanent: true);
    await Get.putAsync<LocationService>(() async => LocationService(),
        permanent: true);
    await Get.putAsync<AudioService>(() async => AudioService(),
        permanent: true);
    await Get.putAsync<ConnectivityService>(() async => ConnectivityService(),
        permanent: true);

    Get.put(LocalStorageService(), permanent: true);

    await Get.putAsync<SyncTaskStorageService>(() async => SyncTaskStorageService(),
        permanent: true);

    final cacheStorageService = Get.find<CacheStorageService>();
    Get.put(SessionController(cacheStorageService), permanent: true);
    Get.lazyPut<ISurveyRepository>(() => SurveyRepository(), fenix: true);
    Get.put(SyncService(), permanent: true);
    Get.put(RevisitStorageService(), permanent: true);

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
