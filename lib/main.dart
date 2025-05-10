// import 'dart:io';
// import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'dart:convert';
// import 'package:geocoding/geocoding.dart';
// import 'package:csv/csv.dart';
// import 'package:diacritic/diacritic.dart';

import 'app/bindings/app_binding.dart';
import 'app/data/models/jumper_model.dart';
import 'app/data/models/sections_model.dart';
import 'app/data/models/survey_model.dart';
import 'app/data/models/survey_question_model.dart';
import 'app/data/models/survey_responded_model.dart';
import 'app/data/models/survey_statistics_model.dart';
import 'app/data/models/surveyor_model.dart';
import 'app/routes/app_routes.dart';
import 'core/services/graphql_service.dart';
import 'core/theme/app_theme.dart';
import 'core/network/graphql_config.dart';
import 'app/data/models/survey_entry_model.dart';
import 'app/data/models/sync_task_model.dart';
import 'app/presentation/controllers/session_controller.dart';
// import 'core/values/location.dart';
import 'core/values/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHive();
  final flutterLocalNotificationsPlugin = await initializeFlutterLocalNotifications();

  await AppBinding().initAsyncDependencies(flutterLocalNotificationsPlugin);

  // await enrichLocationData();
  runApp(const MyApp());
}

Future<FlutterLocalNotificationsPlugin> initializeFlutterLocalNotifications() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/icon');

  const DarwinInitializationSettings initializationSettingsApple =
  DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true);

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsApple,
      macOS: initializationSettingsApple);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  return flutterLocalNotificationsPlugin;
}

/// **Inicialización de Hive**
Future<void> _initHive() async {
  await initHiveForFlutter();
  Hive.registerAdapter(SurveyEntryModelAdapter());
  Hive.registerAdapter(SyncTaskModelAdapter());
  Hive.registerAdapter(SurveyorModelAdapter());
  Hive.registerAdapter(SurveyStatisticsModelAdapter());
  Hive.registerAdapter(SurveyRespondedModelAdapter());
  Hive.registerAdapter(SurveyModelAdapter());
  Hive.registerAdapter(SurveyQuestionModelAdapter());
  Hive.registerAdapter(JumperModelAdapter());
  Hive.registerAdapter(SectionsModelAdapter());

  await Future.wait([
    Hive.openBox('authBox'),
    Hive.openBox<SyncTaskModel>('sync_tasks'),
    Hive.openBox<SurveyModel>('surveysBox'),
    Hive.openBox<SurveyRespondedModel>('surveysRespondedBox'),
    Hive.openBox<SurveyStatisticsModel>('statisticsBox'),
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
      client: Get.find<GraphQLService>().client,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chiwi Censo',
        theme: AppTheme.theme,
        defaultTransition: Transition.fade,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
        locale: const Locale('es', 'ES'), // Español
        supportedLocales: const [
          Locale('es', 'ES'), // Español
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
