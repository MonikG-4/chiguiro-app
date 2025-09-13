import 'package:get/get.dart';

import '../data/repositories/auth_repository.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IAuthRepository>(() => AuthRepository());
    Get.lazyPut(() => AuthController(Get.find()),);
  }
}