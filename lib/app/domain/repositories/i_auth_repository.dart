import '../entities/auth_response.dart';

abstract class IAuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<bool> forgotPassword(String email);
}