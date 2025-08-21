import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/graphql_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/i_statistic_repository.dart';
import '../graphql/queries/statistic_query.dart';
import '../models/survey_statistics_model.dart';
import 'base_repository.dart';

class StatisticRepository extends BaseRepository
    implements IStatisticRepository {
  final GraphQLService _graphqlService = Get.find<GraphQLService>();
  final LocalStorageService _localStorageService = Get.find();

  StatisticRepository();

  @override
  Future<Either<Failure, Statistic>> fetchStatistics(
      int surveyorId,) async {
    return safeApiCallWithCache<Statistic>(
      request: () => _graphqlService.query(
        document: StatisticQuery.statistics,
        variables: {
          'pollsterId': surveyorId,
        },
      ),
      onSuccess: (data) => StatisticsModel.fromJson(data['pollsterStatistic2']).toEntity(),
      dataKey: 'pollsterStatistic2',
      getCacheData: () async => _localStorageService.getStatisticsSurvey(surveyorId),
      saveToCache: (statistics) => _localStorageService.saveStatisticsSurvey(surveyorId, statistics),
      unknownErrorMessage: 'No se encontraron estadísticas de la encuesta',
    );
  }

}