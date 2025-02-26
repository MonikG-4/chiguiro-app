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
  Future<Survey> fetchActiveSurveys(int surveyId) async {
    final result =
        await processRequest(() => provider.fetchActiveSurveys(surveyId));

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    if (result.data == null || result.data!['project'] == null) {
      throw Exception('No se encontraron encuestas');
    }

    return SurveyModel.fromJson(result.data!['project']).toEntity();
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

  @override
  Future<List<Sections>> fetchSurveyQuestions(int surveyId) async {
    final result =
    await processRequest(() => provider.fetchSurveyQuestions(surveyId));

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    if (result.data == null || result.data!['sections'] == null) {
      throw Exception('No se encontraron preguntas de la encuesta');
    }

    return (result.data!['sections'] as List)
        .map((element) => SectionsModel.fromJson(Map<String, dynamic>.from(element)).toEntity())
        .toList();
  }
}
