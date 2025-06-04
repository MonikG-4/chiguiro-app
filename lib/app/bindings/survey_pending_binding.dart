import 'package:get/get.dart';

import '../domain/repositories/i_survey_repository.dart';
import '../presentation/controllers/pending_survey_controller.dart';

class SurveyPendingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PendingSurveyController(Get.find<ISurveyRepository>()));
  }
}
