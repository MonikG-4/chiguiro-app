import 'package:get/get.dart';

import '../../../core/values/routes.dart';
import 'session_controller.dart';

class SettingsController extends GetxController {

  void goToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  void goToChangePassword() {
    Get.toNamed(Routes.CHANGE_PASSWORD);
  }

  void goToPermissions() {
    Get.toNamed(Routes.PERMISSIONS);
  }

  void logout() {
    final sessionController = Get.find<SessionController>();
    sessionController.logout();
  }
}
