import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/error/exceptions/exceptions.dart';
import '../../../core/error/failures/failure.dart';
import '../../../core/services/graphql_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/survey_responded.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_home_repository.dart';
import '../graphql/mutations/password_mutations.dart';
import '../graphql/queries/survey_query.dart';
import '../graphql/queries/survey_responded_query.dart';
import '../graphql/queries/surveyor_query.dart';
import '../models/survey_model.dart';
import '../models/survey_responded_model.dart';
import '../models/surveyor_model.dart';
import 'base_repository.dart';

class HomeRepository extends BaseRepository implements IHomeRepository {
  final GraphQLService _graphqlService = Get.find<GraphQLService>();
  final LocalStorageService _localStorageService = Get.find();

  HomeRepository();

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

  @override
  Future<Either<Failure, List<Survey>>> fetchSurveys(int surveyorId,
      {bool forceServer = false}) async {
    if (!_localStorageService.projectsEmpty() && forceServer == false) {
      print(
          "Engage from LOCAL ==================================================================================");
      return Right(_localStorageService.getSurveys());
    }

    print(
        "Engage from SERVER ====================================================================================");

    return safeApiCallWithCache<List<Survey>>(
      request: () => _graphqlService.query(
        document: SurveyQuery.pollstersProjectByPollster,
        variables: {
          'pollsterId': surveyorId,
        },
      ),
      onSuccess: (data) => (data['pollstersProjectByPollster'] as List)
          .map((e) => SurveyModel.fromJson(e['project']).toEntity())
          .toList(),
      dataKey: 'pollstersProjectByPollster',
      getCacheData: () async => _localStorageService.getSurveys(),
      saveToCache: (surveys) => _localStorageService.saveSurveys(surveys),
      unknownErrorMessage: 'No se encontraron encuestas asignadas',
    );
  }

  @override
  Future<Either<Failure, Surveyor>> fetchDataSurveyor(int surveyorId) async {
    return safeApiCallWithCache<Surveyor>(
      request: () => _graphqlService.query(
        document: SurveyorQuery.surveyor,
        variables: {
          'id': surveyorId,
        },
      ),
      onSuccess: (data) =>
          SurveyorModel.fromJson(data['pollsterHome']).toEntity(),
      dataKey: 'pollsterHome',
      getCacheData: () async {
        final surveyor = _localStorageService.getSurveyor();
        if (surveyor == null) {
          throw CacheException('No se encontró información del encuestador');
        }
        return surveyor;
      },
      saveToCache: (surveyor) => _localStorageService.saveSurveyor(surveyor),
      unknownErrorMessage: 'No se encontraron datos del encuestador',
    );
  }

  @override
  Future<Either<Failure, List<SurveyResponded>>> fetchSurveyResponded(
      String homeCode, int surveyorId) async {
    return safeApiCallWithCache<List<SurveyResponded>>(
      request: () => _graphqlService.query(
        document: SurveyRespondedQuery.pollsterStatisticHome,
        variables: {
          'homeCode': homeCode,
          'pollsterId': surveyorId,
        },
      ),
      onSuccess: (data) => (data['pollsterStatisticHome'] as List)
          .map((e) => SurveyRespondedModel.fromJson(e).toEntity())
          .toList(),
      dataKey: 'pollsterStatisticHome',
      getCacheData: () async => _localStorageService.getSurveysResponded(),
      saveToCache: (surveys) =>
          _localStorageService.saveSurveysResponded(surveys),
      unknownErrorMessage: 'No se encontraron encuestas respondidas',
    );
  }
}
