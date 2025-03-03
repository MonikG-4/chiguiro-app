import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../app/presentation/controllers/session_controller.dart';
import '../services/connectivity_service.dart';

class NetworkRequestInterceptor {
  final SessionController _sessionController = Get.find<SessionController>();
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();

  Future<QueryResult> handleRequest(Future<QueryResult> Function() request) async {
    await _connectivityService.waitForInitialization();

    if (!_connectivityService.isConnected.value) {
      throw Exception("No hay conexión a internet. Por favor, verifica tu red.");
    }

    final result = await request();

    if (result.hasException) {
      final errorMessages = result.exception?.graphqlErrors.map((e) => e.message).toList() ?? [];

      if (errorMessages.contains("No user Logged!")) {
        _sessionController.handleSessionExpired();
        throw Exception("Tu sesión ha expirado. Por favor, inicia sesión nuevamente.");
      }

      throw Exception(errorMessages.join(", "));
    }

    return result;
  }
}
