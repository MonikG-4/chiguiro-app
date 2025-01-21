import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../providers/auth_provider.dart';

class AuthRepository implements IAuthRepository {
  final AuthProvider provider;

  AuthRepository(this.provider);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final result = await provider.login(email, password);

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw Exception(error?.message ?? 'Error desconocido');
      }

      if (result.data == null || result.data!['login'] == null) {
        throw Exception('Datos de login inválidos');
      }
      return AuthResponse.fromJson(result.data!['login']);
    } catch (e) {
      throw Exception('Error en el login: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final result = await provider.forgotPassword(email);

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw Exception(error?.message ?? 'Error desconocido');
      }

    } catch (e) {
      throw Exception('Error en el forgotPassword: $e');
    }
  }
}
