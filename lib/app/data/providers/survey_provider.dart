import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/mutations/survey_mutation.dart';

class SurveyProvider {
  final GraphQLClient client;

  SurveyProvider(this.client);

  Future<QueryResult> saveSurveyResults(Map<String, dynamic> entryInput) async {
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
