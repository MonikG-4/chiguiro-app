import '../../domain/entities/sections.dart';
import '../../domain/repositories/i_survey_repository.dart';
import '../providers/survey_provider.dart';

class SurveyRepository implements ISurveyRepository {
  final SurveyProvider provider;

  SurveyRepository(this.provider);

  @override
  Future<List<Sections>> fetchSurveyQuestions(int surveyId) async {
    try {
      final result = await provider.fetchSurveyQuestions(surveyId);

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw Exception(error?.message ?? 'Error desconocido');
      }

      if (result.data == null || result.data!['sections'] == null) {
        throw Exception('No se encontraron preguntas de la encuesta');
      }

      return (result.data!['sections'] as List)
          .map((element) =>
          Sections.fromJson(Map<String, dynamic>.from(element)))
          .toList();

    } catch (e) {
      throw Exception('Error al obtener las preguntas de la encuesta: $e');
    }
  }

  @override
  Future<bool> saveSurveyResults(Map<String, dynamic> entryInput) async {
    try {
      final result = await provider.saveSurveyResults(entryInput);

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw Exception(error?.message ?? 'Error desconocido');
      }

      if (result.data == null || result.data!['entry'] == null) {
        throw Exception('No se logro enviar la encuesta, intente nuevamente');
      }

      return result.data!['entry'].isNotEmpty;

    } catch (e) {
      throw Exception('Error al guardar las respuestas de la encuesta: $e');
    }
  }
}
