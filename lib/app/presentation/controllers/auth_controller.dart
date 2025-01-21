import 'package:get/get.dart';
import '../../../core/values/routes.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'auth_storage_controller.dart';

class AuthController extends GetxController {
  final IAuthRepository repository;
  final AuthStorageController _authStorageController =
      Get.find<AuthStorageController>();

  final isLoading = false.obs;
  final message = ''.obs;
  final stateMessage = ''.obs;

  String get messageValue => message.value;
  String get stateMessageValue => stateMessage.value;

  AuthController(this.repository);

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      message.value = '';
      stateMessage.value = '';

      final response = await repository.login(email, password);

      await _authStorageController.saveAuthResponse(response);

      Get.offAllNamed(Routes.DASHBOARD_SURVEYOR);
    } catch (e) {
      message.value = e.toString().replaceAll("Exception:", "");
      stateMessage.value = 'error';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      message.value = '';
      stateMessage.value = '';

      await repository.forgotPassword(email);

      // message.value =
      //     'Se envio un E-Mail con indicaciones para restablecer la contraseña.';
      // stateMessage.value = 'success';

    } catch (e) {
      message.value = e.toString().replaceAll("Exception:", "");
      stateMessage.value = 'error';
    } finally {
      isLoading.value = false;
    }
  }

  void deleteMessage() {
    message.value = '';
    stateMessage.value = '';
  }
}
