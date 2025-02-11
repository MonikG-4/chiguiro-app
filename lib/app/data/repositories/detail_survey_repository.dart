import '../../domain/entities/detail_survey.dart';
import '../../domain/repositories/i_detail_survey_repository.dart';
import '../providers/detail_survey_provider.dart';

class DetailSurveyRepository implements IDetailSurveyRepository {
  final DetailSurveyProvider provider;

  DetailSurveyRepository(this.provider);

  @override
  Future<List<DetailSurvey>> getSurveyDetail(int surveyId, int pageIndex, int pageSize) async {
    try {
      final result = await provider.getSurveyDetail(surveyId, pageIndex, pageSize);

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.first;
        throw Exception(error?.message ?? 'Error desconocido');
      }

      if (result.data == null || result.data!['entries']['elements'] == null) {
        throw Exception('No se encontraron detalles de la encuesta');
      }

      return (result.data!['entries']['elements'] as List)
          .map((element) =>
          DetailSurvey.fromJson(Map<String, dynamic>.from(element)))
          .toList();

    } catch (e) {
      throw Exception('Error al obtener el detalle de la encuesta: $e');
    }
  }
}
