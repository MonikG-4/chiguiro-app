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

      message.update((val) {
        val?.message = e.toString().replaceAll("Exception:", "");
        val?.state = 'error';
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;

      await repository.forgotPassword(email);

      message.update((val) {
        val?.message = 'Se envio un E-Mail con indicaciones para restablecer la contraseña.';
        val?.state = 'success';
      });

    } catch (e) {
      message.update((val) {
        val?.message = e.toString().replaceAll("Exception:", "");
        val?.state = 'error';
      });
    } finally {
      isLoading.value = false;
    }
  }
}
