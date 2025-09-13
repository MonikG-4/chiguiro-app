import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/graphql_service.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../graphql/mutations/password_mutations.dart';
import 'base_repository.dart';

class SettingsRepository extends BaseRepository implements ISettingsRepository {
  final GraphQLService _graphqlService = Get.find<GraphQLService>();

  SettingsRepository();

  @override
  Future<Either<Failure, bool>> changePassword(
      int pollsterId, String password) async {
    return safeApiCall<bool>(
      request: () => _graphqlService.mutate(
        document: PasswordMutations.pollsterChangePassword,
        variables: {"id": pollsterId, "password": password},
      ),
      onSuccess: (data) => data['pollsterChangePassword'] == null,
      dataKey: 'pollsterChangePassword',
    );
  }

}
