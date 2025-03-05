import 'package:get/get.dart';

import '../../../core/error/exceptions/exceptions.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../domain/entities/detail_survey.dart';
import '../../domain/entities/survey_statistics.dart';
import '../../domain/repositories/i_detail_survey_repository.dart';
import '../models/survey_statistics_model.dart';
import '../providers/detail_survey_provider.dart';
import 'base_repository.dart';

class DetailSurveyRepository extends BaseRepository
    implements IDetailSurveyRepository {
  final DetailSurveyProvider provider;
  final ConnectivityService _connectivityService = Get.find();
  final LocalStorageService _localStorageService = Get.find();

  DetailSurveyRepository(this.provider);

  @override
  Future<SurveyStatistics> fetchStatisticsSurvey(
      int surveyorId, int surveyId) async {
    if (_connectivityService.isConnected.value) {
      final result = await processRequest(
          () => provider.fetchStatisticsSurvey(surveyorId, surveyId));

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw ServerException(error?.message ?? 'Error desconocido');
      }

      if (result.data == null || result.data!['pollsterStatistic'] == null) {
        throw UnknownException('No se encontraron estadísticas de la encuesta');
      }

      final surveyStatistics =
          SurveyStatisticsModel.fromJson(result.data!['pollsterStatistic'])
              .toEntity();
      

      _localStorageService.saveStatisticsSurvey(surveyId, surveyStatistics);
      return surveyStatistics;
    } else {
      try {
        return Future.value(
            _localStorageService.getStatisticsSurvey(surveyId) ??
                (throw UnknownException(
                    'No se encontraron estadísticas de la encuesta')));
      } on CacheException {
        throw CacheException('Error desconocido');
      }
    }
  }

  @override
  Future<List<DetailSurvey>> fetchSurveyDetail(
      int surveyorId, int surveyId, int pageIndex, int pageSize) async {
    final result = await processRequest(() =>
        provider.fetchSurveyDetail(surveyorId, surveyId, pageIndex, pageSize));

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    if (result.data == null ||
        result.data!['pollsterEntries']['elements'] == null) {
      throw Exception('No se encontraron detalles de la encuesta');
    }

    return (result.data!['pollsterEntries']['elements'] as List)
        .map((element) =>
            DetailSurvey.fromJson(Map<String, dynamic>.from(element)))
        .toList();
  }
}
