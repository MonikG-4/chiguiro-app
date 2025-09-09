import 'package:get/get.dart';

import '../data/repositories/statistic_repository.dart';
import '../domain/repositories/i_statistic_repository.dart';

import '../data/repositories/pending_survey_repository.dart';
import '../domain/repositories/i_pending_survey_repository.dart';

import '../presentation/controllers/statistic_controller.dart';

class StatisticBinding extends Bindings {
  @override
  void dependencies() {
    // Repos
    Get.lazyPut<IStatisticRepository>(() => StatisticRepository(), fenix: true);
    Get.lazyPut<IPendingSurveyRepository>(() => PendingSurveyRepository(), fenix: true);

    // Controller con ambos repos
    Get.lazyPut<StatisticController>(
          () => StatisticController(
        Get.find<IStatisticRepository>(),
        Get.find<IPendingSurveyRepository>(),
      ),
      fenix: true,
    );
  }
}
