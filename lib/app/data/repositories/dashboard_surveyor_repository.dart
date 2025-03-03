import '../../domain/entities/sections.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_dashboard_surveyor_repository.dart';
import '../models/sections_model.dart';
import '../models/survey_model.dart';
import '../models/surveyor_model.dart';
import '../providers/dashboard_surveyor_provider.dart';
import 'base_repository.dart';

class DashboardSurveyorRepository extends BaseRepository
    implements IDashboardSurveyorRepository {
  final DashboardSurveyorProvider provider;

  DashboardSurveyorRepository(this.provider);

  @override
  Future<bool> changePassword(int pollsterId, String password) async {
    final result = await processRequest(() => provider.changePassword(pollsterId, password));

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    return result.data!['pollsterChangePassword'] == null;
  }

  @override
  Future<List<Survey>> fetchActiveSurveys(int surveyorId) async {
    final result =
        await processRequest(() => provider.fetchActiveSurveys(surveyorId));

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    if (result.data == null || result.data!['pollstersProjectByPollster'] == null) {
      throw Exception('No se encontraron encuestas');
    }

    return (result.data!['pollstersProjectByPollster'] as List)
        .map((e) => SurveyModel.fromJson(e['project']).toEntity())
        .toList();
  }

  @override
  Future<List<Survey>> getHistoricalSurveys() =>
      provider.getHistoricalSurveys();

  @override
  Future<Surveyor> getSurveyorProfile(int surveyorId) async {
    final result =
        await processRequest(() => provider.getSurveyorProfile(surveyorId));


    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    if (result.data == null || result.data!['pollster'] == null) {
      throw Exception('No se encontraron datos del encuestador');
    }

    return SurveyorModel.fromJson(result.data!['pollster']).toEntity();
  }
}
