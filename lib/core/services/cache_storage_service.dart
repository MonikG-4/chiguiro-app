import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../app/domain/entities/auth_response.dart';

class CacheStorageService extends GetxService {
  final _cachedAuthResponse = Rx<AuthResponse?>(null);
  final _cachedToken = Rx<String?>(null);
  final _authBox = Hive.box('authBox');

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<CacheStorageService> init() async {
    final authResponseJson = _authBox.get('authResponse');

    if (authResponseJson != null) {
      _cachedAuthResponse.value =
          AuthResponse.fromJson(Map<String, dynamic>.from(authResponseJson));
      _cachedToken.value = _cachedAuthResponse.value?.accessToken;
    }

    return this;
  }

  String? get token => _cachedToken.value;
  AuthResponse? get authResponse => _cachedAuthResponse.value;
  bool get isAuthenticated => _cachedToken.value != null;

  Future<void> saveAuthResponse(AuthResponse authResponse) async {
    await _authBox.put('authResponse', authResponse.toJson());
    _cachedAuthResponse.value = authResponse;
    _cachedToken.value = authResponse.accessToken;
  }

  Future<void> clearData() async {
    await _authBox.delete('authResponse');
    _cachedAuthResponse.value = null;
    _cachedToken.value = null;
  }
}
