import 'package:get/get.dart';

import '../../core/network/graphql_config.dart';
import '../data/providers/survey_provider.dart';
import '../data/repositories/survey_repository.dart';
import '../domain/repositories/i_survey_repository.dart';
import '../presentation/controllers/survey_controller.dart';

class SurveyBinding extends Bindings {
  @override
  void dependencies() {
    final graphQLClient = GraphQLConfig.initializeClient().value;

    Get.lazyPut(() => SurveyProvider(graphQLClient));

    Get.lazyPut<ISurveyRepository>( () => SurveyRepository(Get.find<SurveyProvider>()));

    Get.lazyPut(() => SurveyController(Get.find<ISurveyRepository>()));

  }
}
