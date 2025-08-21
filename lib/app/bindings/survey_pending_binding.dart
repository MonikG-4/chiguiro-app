import 'package:get/get.dart';

import '../data/repositories/pending_survey_repository.dart';
import '../domain/repositories/i_pending_survey_repository.dart';
import '../presentation/controllers/pending_survey_controller.dart';

class PendingSurveyBinding extends Bindings {
  @override
  void dependencies() {

    Get.put<IPendingSurveyRepository>( PendingSurveyRepository());
    Get.put(PendingSurveyController(Get.find<IPendingSurveyRepository>()));
  }
}
