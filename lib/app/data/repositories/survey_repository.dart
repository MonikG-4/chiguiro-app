import '../../domain/entities/survey_question.dart';
import '../../domain/repositories/i_survey_repository.dart';
import '../providers/survey_provider.dart';

class SurveyRepository implements ISurveyRepository {
  final SurveyProvider provider;

  SurveyRepository(this.provider);

  @override
  Future<List<SurveyQuestion>> fetchSurveyQuestions(int surveyId) async {
    try {
      final result = await provider.fetchSurveyQuestions(surveyId);

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw Exception(error?.message ?? 'Error desconocido');
      }

      if (result.data == null || result.data!['questions'] == null) {
        throw Exception('No se encontraron preguntas de la encuesta');
      }

      return (result.data!['questions'] as List)
          .map((element) =>
          SurveyQuestion.fromJson(Map<String, dynamic>.from(element)))
          .toList();

    } catch (e) {
      throw Exception('Error al obtener las preguntas de la encuesta: $e');
    }
  }
}
