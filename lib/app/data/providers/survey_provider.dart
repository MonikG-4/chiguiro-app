import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/mutations/survey_mutation.dart';
import '../graphql/queries/survey_query.dart';

class SurveyProvider {
  final GraphQLClient client;

  SurveyProvider(this.client);

  Future<QueryResult> fetchSurveyQuestions(int surveyId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(SurveyQuery.sections),
        variables: {
          'projectId': surveyId,
        },
      );
      final result = await client.query(options);

      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<QueryResult> saveSurveyResults(Map<String, dynamic> entryInput, String token) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(SurveyMutation.entry),
        variables: {
          'input': entryInput,
        },
      );

      final result = await client.mutate(options);
      return result;
    } catch (e) {
      throw Exception('Error al guardar las respuestas de la encuesta: $e');
    }
  }

}
