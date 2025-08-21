import 'package:get/get.dart';
import '../data/repositories/home_repository.dart';
import '../domain/repositories/i_home_repository.dart';
import '../presentation/controllers/revisit_detail_controller.dart';

class RevisitDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IHomeRepository>( HomeRepository());
    Get.put(RevisitDetailController(Get.find<IHomeRepository>()));
  }
}
