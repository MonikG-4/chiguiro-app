import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/bindings/app_binding.dart';
import 'app/data/models/jumper_model.dart';
import 'app/data/models/revisit_model.dart';
import 'app/data/models/sections_model.dart';
import 'app/data/models/statistic_day_model.dart';
import 'app/data/models/survey_model.dart';
import 'app/data/models/survey_question_model.dart';
import 'app/data/models/survey_responded_model.dart';
import 'app/data/models/survey_statistics_model.dart';
import 'app/data/models/surveyor_model.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'app/data/models/survey_entry_model.dart';
import 'app/data/models/sync_task_model.dart';
import 'app/presentation/controllers/session_controller.dart';
import 'core/values/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHive();

  await AppBinding().initAsyncDependencies();

  runApp(const MyApp());
}

/// **Inicialización de Hive**
Future<void> _initHive() async {
  await initHiveForFlutter();
  Hive.registerAdapter(SurveyEntryModelAdapter());
  Hive.registerAdapter(SyncTaskModelAdapter());
  Hive.registerAdapter(SurveyorModelAdapter());
  Hive.registerAdapter(StatisticsModelAdapter());
  Hive.registerAdapter(StatisticDayModelAdapter());
  Hive.registerAdapter(SurveyRespondedModelAdapter());
  Hive.registerAdapter(SurveyModelAdapter());
  Hive.registerAdapter(SurveyQuestionModelAdapter());
  Hive.registerAdapter(JumperModelAdapter());
  Hive.registerAdapter(SectionsModelAdapter());
  Hive.registerAdapter(RevisitModelAdapter());

  await Future.wait([
    Hive.openBox('authBox'),
    Hive.openBox<SyncTaskModel>('sync_tasks'),
    Hive.openBox<SurveyModel>('surveysBox'),
    Hive.openBox<SurveyRespondedModel>('surveysRespondedBox'),
    Hive.openBox<StatisticsModel>('statisticsBox'),
    Hive.openBox<SurveyorModel>('surveyorBox'),
    Hive.openBox<RevisitModel>('revisitsBox'),
  ]);
}

/// **Clase principal de la app**
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = Get.find<SessionController>().isAuthenticated.value
        ? Routes.DASHBOARD
        : Routes.LOGIN;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chiwi Censo',
      theme: AppTheme.theme,
      defaultTransition: Transition.fade,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      locale: const Locale('es', 'ES'),
      // Español
      supportedLocales: const [
        Locale('es', 'ES'), // Español
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
