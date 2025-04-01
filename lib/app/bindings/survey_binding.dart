import 'package:get/get.dart';

import '../data/providers/survey_provider.dart';
import '../data/repositories/survey_repository.dart';
import '../domain/repositories/i_survey_repository.dart';
import '../presentation/controllers/survey_controller.dart';

class SurveyBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut(() => SurveyProvider(), fenix: true);
    Get.lazyPut<ISurveyRepository>(() => SurveyRepository(Get.find<SurveyProvider>()), fenix: true);
    Get.lazyPut(() => SurveyController(Get.find<ISurveyRepository>()), fenix: true);
  }
}
