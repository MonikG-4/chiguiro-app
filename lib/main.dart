import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'app/presentation/controllers/auth_storage_controller.dart';
import 'app/presentation/controllers/session_controller.dart';
import 'app/routes/app_routes.dart';
import 'core/network/graphql_config.dart';
import 'core/theme/app_theme.dart';
import 'core/values/routes.dart';

void main() async {
  await initHiveForFlutter();
  await Get.putAsync<AuthStorageController>(() async {
    final controller = AuthStorageController();
    await controller.initialize();
    return controller;
  }, permanent: true);

  Get.put(SessionController(Get.find<AuthStorageController>()), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.find<SessionController>();
    final initialRoute = sessionController.isAuthenticated
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
