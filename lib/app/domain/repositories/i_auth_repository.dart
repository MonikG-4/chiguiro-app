import '../entities/auth_response.dart';

abstract class IAuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<void> forgotPassword(String email);
}