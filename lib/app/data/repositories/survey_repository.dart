import '../../domain/repositories/i_survey_repository.dart';
import '../providers/survey_provider.dart';
import 'base_repository.dart';

class SurveyRepository extends BaseRepository implements ISurveyRepository {
  final SurveyProvider provider;

  SurveyRepository(this.provider);

  @override
  Future<bool> saveSurveyResults(Map<String, dynamic> entryInput) async {
    final result =
        await processRequest(() => provider.saveSurveyResults(entryInput));

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.first;
      throw Exception(error?.message ?? 'Error desconocido');
    }

    if (result.data == null || result.data!['entry'] == null) {
      throw Exception('No se logro enviar la encuesta, intente nuevamente');
    }

    return result.data!['entry'].isNotEmpty;
  }
}
