import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/presentation/controllers/session_controller.dart';
import '../values/routes.dart';

class SessionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<SessionController>();
    if (authController.isAuthenticated) {
      return null;
    }

    return const RouteSettings(name: Routes.LOGIN);
  }
}