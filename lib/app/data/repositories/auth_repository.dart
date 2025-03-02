import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../providers/auth_provider.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository implements IAuthRepository {
  final AuthProvider provider;

  AuthRepository(this.provider);

  @override
  Future<AuthResponse> login(String email, String password) async {
    final result = await processRequest(() => provider.login(email, password));

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    if (result.data == null || result.data!['pollsterLogin'] == null) {
      throw Exception('Datos de login inválidos');
    }

    return AuthResponse.fromJson(result.data!['pollsterLogin']);
  }

  @override
  Future<bool> forgotPassword(String email) async {
    final result = await processRequest(() => provider.forgotPassword(email));

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    return result.data!['pollsterForgotPassword'] == null;
  }
}
