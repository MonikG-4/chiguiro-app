import 'package:dartz/dartz.dart';

import '../../../core/error/failures/failure.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../providers/auth_provider.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository implements IAuthRepository {
  final AuthProvider provider;

  AuthRepository(this.provider);

  @override
  Future<Either<Failure, AuthResponse>> login(
      String email, String password) async {
    return safeApiCall<AuthResponse>(
      request: () => provider.login(email, password),
      onSuccess: (data) => AuthResponse.fromJson(data['pollsterLogin']),
      dataKey: 'pollsterLogin',
      unknownErrorMessage: 'Datos de login inválidos',
    );
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    return safeApiCall<bool>(
      request: () => provider.forgotPassword(email),
      onSuccess: (data) => data['pollsterForgotPassword'] == null,
      dataKey: 'pollsterForgotPassword',
    );
  }
}
