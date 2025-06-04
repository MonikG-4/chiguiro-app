import 'package:get/get.dart';

import '../presentation/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SettingsController() , permanent: true);
  }
}
