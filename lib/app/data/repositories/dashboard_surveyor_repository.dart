import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/error/exceptions/exceptions.dart';
import '../../../core/error/failures/failure.dart';
import '../../../core/services/local_storage_service.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_dashboard_surveyor_repository.dart';
import '../models/survey_model.dart';
import '../models/surveyor_model.dart';
import '../providers/dashboard_surveyor_provider.dart';
import 'base_repository.dart';

class DashboardSurveyorRepository extends BaseRepository
    implements IDashboardSurveyorRepository {
  final DashboardSurveyorProvider provider;
  final LocalStorageService _localStorageService = Get.find();

  DashboardSurveyorRepository(this.provider);

  @override
  Future<Either<Failure, bool>> changePassword(
      int pollsterId, String password) async {
    return safeApiCall<bool>(
      request: () => provider.changePassword(pollsterId, password),
      onSuccess: (data) => data['pollsterChangePassword'] == null,
      dataKey: 'pollsterChangePassword',
    );
  }

  @override
  Future<Either<Failure, List<Survey>>> fetchSurveys(int surveyorId) async {
    return safeApiCallWithCache<List<Survey>>(
      request: () => provider.fetchSurveys(surveyorId),
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
      request: () => provider.fetchDataSurveyor(surveyorId),
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
}
