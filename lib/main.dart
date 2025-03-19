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

// Future<void> enrichLocationData() async {
//   final locationData = LocationData.getLocationData(); // JSON existente
//
//   try {
//     // 📌 Leer el archivo CSV
//     final csvString = await rootBundle.loadString('assets/dane.csv');
//     final csvRows = const CsvToListConverter(fieldDelimiter: ';', eol: '\n')
//         .convert(csvString);
//
//     // 📌 Mapas para búsqueda rápida
//     final Map<String, String> departmentCodes = {};
//     final Map<String, Map<String, String>> cityCodes = {};
//
//     for (var row in csvRows.skip(1)) {
//       if (row.length >= 4) {
//         String deptCode = row[0].toString();
//         String cityCode = row[1].toString();
//         String department = row[2].toString().trim();
//         String city = row[3].toString().trim();
//
//         // 🔹 Normalizar nombres eliminando acentos y caracteres especiales
//         String deptKey = normalizeText(department);
//         String cityKey = normalizeText(city);
//
//         departmentCodes[deptKey] = deptCode;
//         cityCodes.putIfAbsent(deptKey, () => {});
//         cityCodes[deptKey]![cityKey] = cityCode;
//       }
//     }
//
//     // 📌 Recorrer el JSON y agregar los códigos sin modificar los nombres
//     for (var country in locationData['countries']) {
//       for (var department in country['departments']) {
//         String departmentName = department['departamento'].toString().trim();
//         String deptKey = normalizeText(departmentName);
//
//         if (departmentCodes.containsKey(deptKey)) {
//           department['departamento'] =
//           "${departmentCodes[deptKey]} - $departmentName";
//         }
//
//         for (var city in department['ciudades']) {
//           String cityName = city['name'].toString().trim();
//           String cityKey = normalizeText(cityName);
//
//           if (cityCodes.containsKey(deptKey) &&
//               cityCodes[deptKey]!.containsKey(cityKey)) {
//             city['name'] = "${cityCodes[deptKey]![cityKey]} - $cityName";
//           }
//         }
//       }
//     }
//
// // 📌 Guardar el JSON actualizado
//     final jsonString = const JsonEncoder.withIndent('  ').convert(locationData);
//
// // 🔹 debugPrint() con wrapWidth para imprimir absolutamentetodo
//     debugPrint(jsonString, wrapWidth: 1024);
//   } catch (e) {
//     print("❌ Error al cargar el archivo CSV: $e");
//   }
// }
//
// String normalizeText(String text) {
//   return removeDiacritics(text) // 📌 Elimina acentos (Ej: "Pacó" -> "Paco")
//       .toLowerCase()
//       .replaceAll(RegExp(r'\(.*?\)'), '') // 📌 Elimina contenido entre paréntesis
//       .replaceAll(RegExp(r'[^a-z\s]'), '') // 📌 Elimina caracteres no alfabéticos
//       .trim();
// }


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
