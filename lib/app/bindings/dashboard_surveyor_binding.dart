import 'package:get/get.dart';

import '../../core/network/graphql_config.dart';
import '../data/providers/dashboard_surveyor_provider.dart';
import '../data/repositories/dashboard_surveyor_repository.dart';
import '../domain/repositories/i_dashboard_surveyor_repository.dart';
import '../presentation/controllers/dashboard_surveyor_controller.dart';

class DashboardSurveyorBinding extends Bindings {
  @override
  void dependencies() {
    final graphQLClient = GraphQLConfig.initializeClient().value;

    Get.lazyPut(() => DashboardSurveyorProvider(graphQLClient));

    Get.lazyPut<IDashboardSurveyorRepository>(
          () => DashboardSurveyorRepository(Get.find<DashboardSurveyorProvider>()),
    );
    Get.lazyPut(() => DashboardSurveyorController(Get.find<IDashboardSurveyorRepository>()));
  }
}
