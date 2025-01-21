import 'package:chiguiro_front_app/app/presentation/controllers/dashboard_surveyor_controller.dart';
import 'package:get/get.dart';

import '../../core/network/graphql_config.dart';
import '../data/providers/survey_provider.dart';
import '../data/repositories/survey_repository.dart';
import '../domain/repositories/i_survey_repository.dart';

class DashboardSurveyorBinding extends Bindings {
  @override
  void dependencies() {
    final graphQLClient = GraphQLConfig.initializeClient().value;

    Get.lazyPut(() => SurveyProvider(graphQLClient));

    Get.lazyPut<ISurveyRepository>(
          () => SurveyRepository(Get.find<SurveyProvider>()),
    );
    Get.lazyPut(() => DashboardSurveyorController(Get.find<ISurveyRepository>()));
  }
}
