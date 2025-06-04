import 'package:get/get.dart';
import '../presentation/controllers/revisits_controller.dart';

class RevisitsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RevisitsController());
  }
}
