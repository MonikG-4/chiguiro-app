import 'package:get/get.dart';

import '../data/repositories/home_repository.dart';
import '../data/repositories/pending_survey_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/statistic_repository.dart';
import '../domain/repositories/i_home_repository.dart';
import '../domain/repositories/i_pending_survey_repository.dart';
import '../domain/repositories/i_settings_repository.dart';
import '../domain/repositories/i_statistic_repository.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/pending_survey_controller.dart';
import '../presentation/controllers/permissions_controller.dart';
import '../presentation/controllers/settings_controller.dart';
import '../presentation/controllers/statistic_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IHomeRepository>(() => HomeRepository());
    Get.lazyPut<IPendingSurveyRepository>(() => PendingSurveyRepository());
    Get.lazyPut<IStatisticRepository>(() => StatisticRepository());
    Get.lazyPut<ISettingsRepository>(() => SettingsRepository());

    Get.lazyPut<HomeController>(() => HomeController(Get.find<IHomeRepository>()));
    Get.lazyPut<PendingSurveyController>(() => PendingSurveyController(Get.find()));
    Get.lazyPut<StatisticController>(() => StatisticController(Get.find(), Get.find()));
    Get.lazyPut<SettingsController>(() => SettingsController(Get.find()));

    Get.lazyPut(() => SettingsController(Get.find()));
    Get.lazyPut(() => PermissionsController());
  }
}
