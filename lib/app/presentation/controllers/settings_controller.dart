import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../../core/values/routes.dart';
import '../../domain/repositories/i_settings_repository.dart';
import 'session_controller.dart';

class SettingsController extends GetxController {
  final ISettingsRepository repository;
  late final AuthStorageService _storageService;

  final isChangePasswordLoading = false.obs;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  SettingsController(this.repository);

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<AuthStorageService>();
    MessageHandler.setupSnackbarListener(message);

  }

  Future<void> changePassword(String password) async {
    isChangePasswordLoading.value = true;

    final result = await repository.changePassword(
        _storageService.authResponse!.id, password);

    result.fold((failure) {
      _showMessage('Error',
          _mapFailureToMessage(failure).replaceAll("Exception:", ""), 'error');
    }, (isSuccess) {
      if (isSuccess) {
        Get.back();
        _showMessage('Cambio de contraseña',
            'Su contraseña fue actualizada correctamente', 'success');
      }
    });

    isChangePasswordLoading.value = false;
  }

  void goToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  void goToChangePassword() {
    Get.toNamed(Routes.CHANGE_PASSWORD);
  }

  void goToAccessibility() {
    Get.toNamed(Routes.ACCESSIBILITY);
  }

  void goToPermissions() {
    Get.toNamed(Routes.PERMISSIONS);
  }

  void logout() {
    final sessionController = Get.find<SessionController>();
    sessionController.logout();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return failure.message;
      case NetworkFailure _:
        return 'Sin conexión a internet. Verifica tu conexión.';
      case CacheFailure _:
        return 'No hay datos almacenados. Conecta a internet para obtener datos.';
      default:
        return failure.message;
    }
  }

  void _showMessage(String title, String msg, String state) {
    message.update((val) {
      val?.title = title;
      val?.message = msg;
      val?.state = state;
    });
  }
}
