import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/mutations/password_mutations.dart';
import '../graphql/queries/survey_query.dart';
import '../graphql/queries/surveyor_query.dart';

class DashboardSurveyorProvider {
  final GraphQLClient client;

  DashboardSurveyorProvider(this.client);

  Future<QueryResult> changePassword(int pollsterId, String password) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(PasswordMutations.pollsterChangePassword),
        variables: {
          "id": pollsterId,
          "password": password
        },
      );

      final result = await client.mutate(options);
      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<QueryResult> fetchSurveys(int surveyorId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(SurveyQuery.pollstersProjectByPollster),
        variables: {
          'pollsterId': surveyorId,
        },
      );
      final result = await client.query(options);

      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<QueryResult> fetchDataSurveyor(int surveyorId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(SurveyorQuery.surveyor),
        variables: {
          'id': surveyorId,
        },
      );

      final result = await client.query(options);
      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }
}
