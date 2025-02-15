import 'dart:async';
import 'package:get/get.dart';
import '../../../core/values/routes.dart';
import 'auth_storage_controller.dart';

class SessionController extends GetxController {
  final AuthStorageController authStorageController;
  final RxBool isLoading = true.obs;

  SessionController(this.authStorageController);

  @override
  void onInit() {
    super.onInit();
    initializeSession();
    authStorageController.authResponse.listen((_) {
      update();
    });
  }

  Future<void> initializeSession() async {
    isLoading.value = true;

    final authResponse = authStorageController.authResponse;

    isLoading.value = false;
  }

  bool get isAuthenticated {
    final authResponse = authStorageController.authResponse.value;
    if (authResponse == null) return false;
    return true;
  }

  void checkSessionValidity() {
    if (!isAuthenticated && authStorageController.token != null) {
      handleSessionExpired();
    }
  }

  Future<void> handleSessionExpired() async {
    await authStorageController.clearData();

    Get.snackbar(
      'Sesión expirada',
      'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
      duration: const Duration(seconds: 3),
    );

    // Redirigir al login
    Get.offAllNamed(Routes.LOGIN);
  }

  void logout() async {
    await authStorageController.clearData();
    Get.offAllNamed(Routes.LOGIN);
  }
}
