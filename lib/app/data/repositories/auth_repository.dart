import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/graphql_service.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../graphql/mutations/password_mutations.dart';
import '../graphql/queries/login_query.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository implements IAuthRepository {
  final GraphQLService _graphqlService = Get.find<GraphQLService>();

  @override
  Future<Either<Failure, AuthResponse>> login(
      String email, String password, String deviceToken) async {
    return safeApiCall<AuthResponse>(
      request: () => _graphqlService.query(
        document: LoginQuery.pollsterLogin,
        variables: {
          "email": email,
          "password": password,
          "appCode": deviceToken,
        },
      ),
      onSuccess: (data) => AuthResponse.fromJson(data['pollsterLogin']),
      dataKey: 'pollsterLogin',
      unknownErrorMessage: 'Datos de login inválidos',
    );
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    return safeApiCall<bool>(
      request: () => _graphqlService.mutate(
        document: PasswordMutations.pollsterForgotPassword,
        variables: {
          "email": email,
        },
      ),
      onSuccess: (data) => data['pollsterForgotPassword'] == null,
      dataKey: 'pollsterForgotPassword',
    );
  }
}
