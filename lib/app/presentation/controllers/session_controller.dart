import 'package:get/get.dart';

import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/values/routes.dart';

class SessionController extends GetxController {
  final AuthStorageService _cacheStorageService;
  var isAuthenticated = false.obs;
  final LocalStorageService _localStorageService = Get.find();

  SessionController(this._cacheStorageService);

  @override
  void onInit() {
    super.onInit();
    isAuthenticated.value = _cacheStorageService.isAuthenticated;
  }

  void updateAuthStatus() {
    isAuthenticated.value = _cacheStorageService.isAuthenticated;
  }

  void handleSessionExpired() {
    _cacheStorageService.clearData();
    _localStorageService.clearAll();
    Get.offAllNamed(Routes.LOGIN);
  }

  void logout() async {
    _cacheStorageService.clearData();
    await _localStorageService.clearAll();
    Get.offAllNamed(Routes.LOGIN);
  }
}
