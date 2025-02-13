import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_dashboard_surveyor_repository.dart';
import '../providers/dashboard_surveyor_provider.dart';

class DashboardSurveyorRepository implements IDashboardSurveyorRepository {
  final DashboardSurveyorProvider provider;

  DashboardSurveyorRepository(this.provider);

  @override
  Future<List<Survey>> getActiveSurveys(int projectId) async {
    try {
      final result = await provider.getActiveSurveys(projectId);

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw Exception(error?.message ?? 'Error desconocido');
      }

      if (result.data == null || result.data!['project'] == null) {
        throw Exception('No se encontraron encuestas');
      }

      return [
        Survey.fromJson(Map<String, dynamic>.from(result.data!['project']))
      ];
    } catch (e) {
      throw Exception('Error al obtener las encuestas: $e');
    }
  }

  @override
  Future<List<Survey>> getHistoricalSurveys() =>
      provider.getHistoricalSurveys();

  @override
  Future<Surveyor> getSurveyorProfile() => provider.getSurveyorProfile();
}
