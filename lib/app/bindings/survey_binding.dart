import 'package:get/get.dart';

import '../presentation/controllers/survey_controller.dart';

class SurveyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SurveyController(Get.find()));
  }
}
