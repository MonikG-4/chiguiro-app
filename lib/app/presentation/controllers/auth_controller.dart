import 'package:get/get.dart';

import '../../../core/services/cache_storage_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../../core/values/routes.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'session_controller.dart';

class AuthController extends GetxController {
  final IAuthRepository repository;
  final CacheStorageService _cacheStorageService =
      Get.find<CacheStorageService>();

  final isLoading = false.obs;
  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  AuthController(this.repository);

  @override
  void onInit() {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await repository.login(email, password);

      await _cacheStorageService.saveAuthResponse(response);
      Get.find<SessionController>().updateAuthStatus();

      Get.closeAllSnackbars();
      Get.offAllNamed(Routes.DASHBOARD_SURVEYOR);
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;

      final isSuccess = await repository.forgotPassword(email);

      if (isSuccess) {
        Get.back();
        _showMessage('Olvidar Contraseña', 'Se envio un E-Mail con una constraseña temporal.', 'success');
      }
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoading.value = false;
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
