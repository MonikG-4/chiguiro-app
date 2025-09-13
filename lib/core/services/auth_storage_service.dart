import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../app/domain/entities/auth_response.dart';

class AuthStorageService extends GetxService {
  final _authStorage = Rx<AuthResponse?>(null);
  final _authToken = Rx<String?>(null);
  final _authBox = Hive.box('authBox');

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<AuthStorageService> init() async {
    final authResponseJson = _authBox.get('authResponse');

    if (authResponseJson != null) {
      _authStorage.value =
          AuthResponse.fromJson(Map<String, dynamic>.from(authResponseJson));
      _authToken.value = _authStorage.value?.accessToken;
    }

    return this;
  }

  String? get token => _authToken.value;

  AuthResponse? get authResponse => _authStorage.value;

  bool get isAuthenticated => _authToken.value != null;

  Future<void> saveAuthResponse(AuthResponse authResponse) async {
    await _authBox.put('authResponse', authResponse.toJson());
    _authStorage.value = authResponse;
    _authToken.value = authResponse.accessToken;
  }

  Future<void> clearData() async {
    await _authBox.delete('authResponse');
    _authStorage.value = null;
    _authToken.value = null;
  }
}
