import 'package:get/get.dart';

import '../../core/network/graphql_config.dart';
import '../data/providers/detail_survey_provider.dart';
import '../data/repositories/detail_survey_repository.dart';
import '../domain/repositories/i_detail_survey_repository.dart';
import '../presentation/controllers/detail_survey_controller.dart';

class DetailSurveyBinding extends Bindings {
  @override
  void dependencies() {
    final graphQLClient = GraphQLConfig.initializeClient().value;

    Get.lazyPut(() => DetailSurveyProvider(graphQLClient));

    Get.lazyPut<IDetailSurveyRepository>(
          () => DetailSurveyRepository(Get.find<DetailSurveyProvider>()),
    );
    Get.lazyPut(() => DetailSurveyController(Get.find<IDetailSurveyRepository>()));
  }
}
