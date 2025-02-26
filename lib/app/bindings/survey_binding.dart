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

    Get.put(SurveyProvider(graphQLClient), permanent: true);
    Get.put<ISurveyRepository>(SurveyRepository(Get.find<SurveyProvider>()), permanent: true);
    Get.lazyPut(() => SurveyController(Get.find<ISurveyRepository>()));
  }
}
