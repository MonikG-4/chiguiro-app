import 'package:get/get.dart';

import '../../../core/error/exceptions/exceptions.dart';
import '../../../core/services/connectivity_service.dart';
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
  final ConnectivityService _connectivityService = Get.find();
  final LocalStorageService _localStorageService = Get.find();

  DashboardSurveyorRepository(this.provider);

  @override
  Future<bool> changePassword(int pollsterId, String password) async {
    final result = await processRequest(
        () => provider.changePassword(pollsterId, password));

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    return result.data!['pollsterChangePassword'] == null;
  }

  @override
  Future<List<Survey>> fetchSurveys(int surveyorId) async {
    if (_connectivityService.isConnected.value) {
      final result =
          await processRequest(() => provider.fetchSurveys(surveyorId));

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw ServerException(error?.message ?? 'Error desconocido');
      }

      if (result.data == null ||
          result.data!['pollstersProjectByPollster'] == null) {
        throw UnknownException('No se encontraron encuestas');
      }

      final surveys = (result.data!['pollstersProjectByPollster'] as List)
          .map((e) => SurveyModel.fromJson(e['project']).toEntity())
          .toList();

      _localStorageService.saveSurveys(surveys);

      return surveys;
    } else {
      try {
        return _localStorageService.getSurveys();
      } on CacheException catch (e) {
        throw CacheException(e.message);
      }
    }
  }

  @override
  Future<Surveyor> fetchDataSurveyor(int surveyorId) async {
    if (_connectivityService.isConnected.value) {
      final result =
          await processRequest(() => provider.fetchDataSurveyor(surveyorId));

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw Exception(error?.message ?? 'Error desconocido');
      }

      if (result.data == null || result.data!['pollsterHome'] == null) {
        throw UnknownException('No se encontraron datos del encuestador');
      }

      final surveyor =
          SurveyorModel.fromJson(result.data!['pollsterHome']).toEntity();
      _localStorageService.saveSurveyor(surveyor);

      return surveyor;
    } else {
      try {
        return Future.value(_localStorageService.getSurveyor() ??
            (throw UnknownException(
                'No se encontró información del encuestador')));
      } on CacheException catch (e) {
        throw CacheException(e.message);
      }
    }
  }
}
