import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';

import 'app/data/models/jumper_model.dart';
import 'app/data/models/sections_model.dart';
import 'app/data/models/survey_model.dart';
import 'app/data/models/survey_question_model.dart';
import 'app/data/models/survey_statistics_model.dart';
import 'app/data/models/surveyor_model.dart';
import 'app/routes/app_routes.dart';
import 'core/services/audio_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/location_service.dart';
import 'core/services/sync_notifier.dart';
import 'core/theme/app_theme.dart';
import 'core/network/graphql_config.dart';
import 'core/network/network_request_interceptor.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/sync_task_storage_service.dart';
import 'app/data/models/survey_entry_model.dart';
import 'app/data/models/sync_task_model.dart';
import 'app/presentation/controllers/session_controller.dart';
import 'core/services/cache_storage_service.dart';
import 'core/values/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHive();
  await _initDependencies();

  runApp(const MyApp());
}

/// **Inicialización de dependencias y servicios**
Future<void> _initDependencies() async {
  try {
  final cacheStorageService = await Get.putAsync<CacheStorageService>(() async {
    return CacheStorageService();
  }, permanent: true);

  await Get.putAsync<LocationService>(() async {
    return LocationService();
  }, permanent: true);

  await Get.putAsync<AudioService>(() async {
    return AudioService();
  }, permanent: true);


  Get.put(LocalStorageService(), permanent: true);
  Get.put(SyncTaskStorageService());
  Get.put(SyncService(), permanent: true).onInit();
  final connectivityService = Get.put(ConnectivityService(), permanent: true);
  await connectivityService.waitForInitialization();
  Get.put(SessionController(cacheStorageService), permanent: true);

  Get.put(NetworkRequestInterceptor(), permanent: true);
  Get.put(SyncNotifier(), permanent: true);


  } catch (e) {
    print('Error al inicializar dependencias: $e');
  }
}

/// **Inicialización de Hive**
Future<void> _initHive() async {
  await initHiveForFlutter();
  Hive.registerAdapter(SurveyEntryModelAdapter());
  Hive.registerAdapter(SyncTaskModelAdapter());
  Hive.registerAdapter(SurveyorModelAdapter());
  Hive.registerAdapter(SurveyStatisticsModelAdapter());
  Hive.registerAdapter(SurveyModelAdapter());
  Hive.registerAdapter(SurveyQuestionModelAdapter());
  Hive.registerAdapter(JumperModelAdapter());
  Hive.registerAdapter(SectionsModelAdapter());

  await Future.wait([
    Hive.openBox('authBox'),
    Hive.openBox<SyncTaskModel>('sync_tasks'),
    Hive.openBox<SurveyModel>('surveysBox'),
    Hive.openBox<SurveyorModel>('surveyorBox'),
  ]);
}

/// **Clase principal de la app**
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = Get.find<SessionController>().isAuthenticated.value
        ? Routes.DASHBOARD_SURVEYOR
        : Routes.LOGIN;

    return GraphQLProvider(
      client: GraphQLConfig.initializeClient(),
      child: GetMaterialApp(
        title: 'Chigüiro',
        theme: AppTheme.theme,
        defaultTransition: Transition.fade,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
      ),
    );
  }
}
