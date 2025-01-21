import 'package:get/get.dart';

import '../../core/network/graphql_config.dart';
import '../data/providers/auth_provider.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final graphQLClient = GraphQLConfig.initializeClient().value;

    Get.lazyPut(() => AuthProvider(graphQLClient));
    Get.lazyPut<IAuthRepository>(
          () => AuthRepository(Get.find<AuthProvider>()),
    );
    Get.lazyPut(
          () => AuthController(Get.find<IAuthRepository>()),
    );
  }
}