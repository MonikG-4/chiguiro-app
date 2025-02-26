import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/presentation/controllers/session_controller.dart';
import '../values/routes.dart';

class SessionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final sessionController = Get.find<SessionController>();
    if (!sessionController.isAuthenticated.value) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}
