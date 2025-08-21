import 'package:get/get.dart';

import '../data/repositories/statistic_repository.dart';
import '../domain/repositories/i_statistic_repository.dart';
import '../presentation/controllers/statistic_controller.dart';

class StatisticBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IStatisticRepository>( StatisticRepository());
    Get.put(StatisticController(Get.find<IStatisticRepository>()));
  }
}
