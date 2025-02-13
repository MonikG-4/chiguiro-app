import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries/survey_query.dart';

class SurveyProvider {
  final GraphQLClient client;

  SurveyProvider(this.client);

  Future<QueryResult> fetchSurveyQuestions(int surveyId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(SurveyQuery.questions),
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
}
