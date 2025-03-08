import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
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
  final LocalStorageService _localStorageService = Get.find();

  DetailSurveyRepository(this.provider);

  @override
  Future<Either<Failure, SurveyStatistics>> fetchStatisticsSurvey(
      int surveyorId, int surveyId) async {
    return safeApiCallWithCache<SurveyStatistics>(
      request: () => provider.fetchStatisticsSurvey(surveyorId, surveyId),
      onSuccess: (data) => SurveyStatisticsModel.fromJson(data['pollsterStatistic']).toEntity(),
      dataKey: 'pollsterStatistic',
      getCacheData: () async => _localStorageService.getStatisticsSurvey(surveyId),
      saveToCache: (statistics) => _localStorageService.saveStatisticsSurvey(surveyId, statistics),
      unknownErrorMessage: 'No se encontraron estadísticas de la encuesta',
    );
  }

  @override
  Future<Either<Failure, List<DetailSurvey>>> fetchSurveyDetail(
      int surveyorId, int surveyId, int pageIndex, int pageSize) async {
    return safeApiCall<List<DetailSurvey>>(
      request: () => provider.fetchSurveyDetail(surveyorId, surveyId, pageIndex, pageSize),
      onSuccess: (data) => (data['pollsterEntries']['elements'] as List)
          .map((element) => DetailSurvey.fromJson(Map<String, dynamic>.from(element)))
          .toList(),
      dataKey: 'pollsterEntries',
      unknownErrorMessage: 'No se encontraron detalles de la encuesta',
    );
  }
}