import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/queries/detail_survey_query.dart';

class DetailSurveyProvider {
  final GraphQLClient client;

  DetailSurveyProvider(this.client);

  Future<QueryResult> fetchStatisticsSurvey(int surveyorId, int surveyId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(DetailSurveyQuery.statistics),
        variables: {
          'pollsterId': surveyorId,
          'projectId': surveyId,
        },
      );
      final result = await client.query(options);

      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<QueryResult> fetchSurveyDetail(
      int surveyorId, int surveyId, int pageIndex, int pageSize) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(DetailSurveyQuery.entries),
        variables: {
          'id': surveyorId,
          'projectId': surveyId,
          'page': {
            'pageSize': pageSize,
            'pageIndex': pageIndex,
          }
        },
      );
      final result = await client.query(options);

      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }
}
