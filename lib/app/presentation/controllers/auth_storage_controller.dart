import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../../domain/entities/auth_response.dart';

class AuthStorageController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var _cachedAuthResponse = Rx<AuthResponse?>(null);
  var _cachedToken = Rx<String?>(null);
  var isInitialized = false.obs;

  Rx<AuthResponse?> get authResponse => _cachedAuthResponse;
  String? get token => _cachedToken.value;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    try {
      String? authResponseJson = await _storage.read(key: 'authResponse');
      if (authResponseJson != null) {
        _cachedAuthResponse.value = AuthResponse.fromJson(jsonDecode(authResponseJson));
        _cachedToken.value = _cachedAuthResponse.value?.accessToken;
      }

      print('AuthResponse: $_cachedAuthResponse');
    } finally {
      isInitialized.value = true;
    }
  }

  Future<void> saveAuthResponse(AuthResponse authResponse) async {
    await _storage.write(
      key: 'authResponse',
      value: jsonEncode(authResponse.toJson()),
    );
    _cachedAuthResponse.value = authResponse;
    _cachedToken.value = authResponse.accessToken;
  }

  Future<void> clearData() async {
    await _storage.deleteAll();
    _cachedAuthResponse.value = null;
    _cachedToken.value = null;
  }
}