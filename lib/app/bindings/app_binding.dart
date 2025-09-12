import 'package:get/get.dart';

import '../../core/network/graphql_client_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/graphql_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/revisit_storage_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/sync_task_storage_service.dart';

import '../../core/services/storage_service.dart';
import '../presentation/controllers/text_scale_controller.dart';
import '../presentation/controllers/theme_controller.dart';

import '../data/repositories/survey_repository.dart';
import '../domain/repositories/i_survey_repository.dart';
import '../presentation/controllers/session_controller.dart';

class AppBinding {
  Future<void> initAsyncDependencies() async {
    Get.put(StorageService(), permanent: true);

    await Get.putAsync<NotificationService>(() async {
      final service = NotificationService(Get.find());
      await service.init();
      return service;
    }, permanent: true);

    await Get.putAsync<AuthStorageService>(() async => AuthStorageService(), permanent: true);
    await Get.putAsync<LocationService>(() async => LocationService(), permanent: true);
    await Get.putAsync<AudioService>(() async => AudioService(), permanent: true);
    await Get.putAsync<ConnectivityService>(() async => ConnectivityService(), permanent: true);

    Get.put(LocalStorageService(), permanent: true);

    await Get.putAsync<SyncTaskStorageService>(() async => SyncTaskStorageService(), permanent: true);

    final cacheStorageService = Get.find<AuthStorageService>();
    Get.put(SessionController(cacheStorageService), permanent: true);
    Get.lazyPut<ISurveyRepository>(() => SurveyRepository(), fenix: true);
    Get.put(SyncService(), permanent: true);
    Get.put(RevisitStorageService(), permanent: true);

    Get.put<GraphQLService>(
      GraphQLService(clientProvider: GraphQLClientProvider()),
      permanent: true,
    );

    Get.put(ThemeController(), permanent: true);
    Get.put(TextScaleController(), permanent: true);
  }
}
