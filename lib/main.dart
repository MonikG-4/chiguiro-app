import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

import 'app/bindings/app_binding.dart';
import 'app/data/models/jumper_model.dart';
import 'app/data/models/sections_model.dart';
import 'app/data/models/survey_model.dart';
import 'app/data/models/survey_question_model.dart';
import 'app/data/models/survey_responded_model.dart';
import 'app/data/models/survey_statistics_model.dart';
import 'app/data/models/surveyor_model.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/network/graphql_config.dart';
import 'app/data/models/survey_entry_model.dart';
import 'app/data/models/sync_task_model.dart';
import 'app/presentation/controllers/session_controller.dart';
import 'core/values/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHive();
  final flutterLocalNotificationsPlugin = await initializeFlutterLocalNotifications();

  await AppBinding().initAsyncDependencies(flutterLocalNotificationsPlugin);

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

/// **Inicialización de dependencias y servicios**
Future<void> _initDependencies() async {
  // Future<void> enrichLocationData() async {
  //   final locationData = LocationData.getLocationData();
  //
  //   for (var country in locationData['countries']) {
  //     for (var department in country['departments']) {
  //       final departmentName = "${department['departamento']}, ${country['name']}";
  //       try {
  //         var depLocation = await locationFromAddress(departmentName);
  //         department['latitude'] = depLocation.first.latitude;
  //         department['longitude'] = depLocation.first.longitude;
  //       } catch (e) {
  //         print('No se encontró ubicación para $departmentName');
  //       }
  //
  //       // Convertimos la lista de ciudades a objetos con latitud y longitud
  //       final updatedCities = <Map<String, dynamic>>[];
  //
  //       for (var city in department['ciudades']) {
  //         final cityName = "$city, ${department['departamento']}, ${country['name']}";
  //         try {
  //           var cityLocation = await locationFromAddress(cityName);
  //           updatedCities.add({
  //             'name': city,
  //             'latitude': cityLocation.first.latitude,
  //             'longitude': cityLocation.first.longitude
  //           });
  //         } catch (e) {
  //           print('No se encontró ubicación para $cityName');
  //           updatedCities.add({'name': city}); // Mantiene el nombre aunque no tenga ubicación
  //         }
  //
  //       }
  //
  //       department['ciudades'] = updatedCities;
  //       print('Ubicación actualizada para $departmentName');
  //     }
  //   }
  //
  //   final jsonString = const JsonEncoder.withIndent('  ').convert(locationData);
  //   const int chunkSize = 800;
  //   for (int i = 0; i < jsonString.length; i += chunkSize) {
  //     print(jsonString.substring(
  //         i,
  //         i + chunkSize > jsonString.length
  //             ? jsonString.length
  //             : i + chunkSize));
  //   }
  // }
  //
  // await enrichLocationData();
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
      client: GraphQLConfig.initializeClient(),
      child: GetMaterialApp(
        title: 'Chigüiro',
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
