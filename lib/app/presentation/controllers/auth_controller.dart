import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/cache_storage_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../../core/values/routes.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'notification_controller.dart';
import 'session_controller.dart';

class AuthController extends GetxController {
  final IAuthRepository repository;
  final CacheStorageService _cacheStorageService =
  Get.find<CacheStorageService>();
  final NotificationController _notificationController = Get.find();

  final isLoading = false.obs;
  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  AuthController(this.repository);

  @override
  void onInit() {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;

    print('Device Token: ${_notificationController.deviceToken.value}');

    final result = await repository.login(email, password, _notificationController.deviceToken.value);

    result.fold(
            (failure) {
          _showMessage('Error', _mapFailureToMessage(failure), 'error');
        },
            (response) async {
          await _cacheStorageService.saveAuthResponse(response);
          Get.find<SessionController>().updateAuthStatus();

          Get.closeAllSnackbars();
          Get.offAllNamed(Routes.DASHBOARD);
        }
    );

    isLoading.value = false;
  }

  Future<void> forgotPassword(String email) async {
    isLoading.value = true;

    final result = await repository.forgotPassword(email);

    result.fold(
            (failure) {
          _showMessage('Error', _mapFailureToMessage(failure).replaceAll("Exception:", ""), 'error');
        },
            (isSuccess) {
          if (isSuccess) {
            Get.back();
            _showMessage('Olvidar Contraseña',
                'Se envio un E-Mail con una constraseña temporal.',
                'success');
          }
        }
    );

    isLoading.value = false;
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return failure.message;
      case NetworkFailure _:
        return 'Sin conexión a internet. Verifica tu conexión.';
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