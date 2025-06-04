import 'package:get/get.dart';

import '../data/repositories/detail_survey_repository.dart';
import '../domain/repositories/i_detail_survey_repository.dart';
import '../presentation/controllers/survey_detail_controller.dart';

class DetailSurveyBinding extends Bindings {
  @override
  void dependencies() {

    Get.put<IDetailSurveyRepository>(DetailSurveyRepository(), permanent: true
    );
    Get.put(SurveyDetailController(Get.find<IDetailSurveyRepository>()));

  }
}
