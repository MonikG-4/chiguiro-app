import 'package:get/get.dart';

import '../data/repositories/home_repository.dart';
import '../domain/repositories/i_home_repository.dart';
import '../presentation/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IHomeRepository>( HomeRepository());
    Get.lazyPut<HomeController>(() => HomeController(Get.find<IHomeRepository>()) , fenix: true);
  }
}
