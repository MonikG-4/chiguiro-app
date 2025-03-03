import '../../domain/entities/detail_survey.dart';
import '../../domain/repositories/i_detail_survey_repository.dart';
import '../providers/detail_survey_provider.dart';
import 'base_repository.dart';

class DetailSurveyRepository extends BaseRepository implements IDetailSurveyRepository {
  final DetailSurveyProvider provider;

  DetailSurveyRepository(this.provider);

  @override
  Future<List<DetailSurvey>> fetchSurveyDetail(int surveyorId, int surveyId, int pageIndex, int pageSize) async {
        final result =
        await processRequest(() =>  provider.fetchSurveyDetail(surveyorId, surveyId, pageIndex, pageSize));

        if (result.hasException) {
          final error = result.exception?.graphqlErrors.first;
          throw Exception(error?.message ?? 'Error desconocido');
        }

        if (result.data == null || result.data!['pollsterEntries']['elements'] == null) {
          throw Exception('No se encontraron detalles de la encuesta');
        }

        return (result.data!['pollsterEntries']['elements'] as List)
            .map((element) =>
            DetailSurvey.fromJson(Map<String, dynamic>.from(element)))
            .toList();

  }
}
