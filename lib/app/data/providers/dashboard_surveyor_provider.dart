import 'package:graphql_flutter/graphql_flutter.dart';

import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';
import '../graphql/queries/survey_query.dart';

class DashboardSurveyorProvider {
  final GraphQLClient client;

  DashboardSurveyorProvider(this.client);

  Future<QueryResult> fetchActiveSurveys(int projectId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(SurveyQuery.project),
        variables: {
          'id': projectId,
        },
      );
      final result = await client.query(options);

      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<List<Survey>> getHistoricalSurveys() async {
    // Implement API call
    List<Survey> surveys = [
      // Survey(
      //   id: '1',
      //   name: 'Customer Satisfaction Survey',
      //   active: false,
      //   closeDate: DateTime.now().add(Duration(days: 30)),
      //   entriesCount: 0,
      //   logoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFe4BEwG37Mv0M724WYCTjsNP2UojEL3Oa0Q&s',
      // ),
      // Survey(
      //   id: '2',
      //   name: 'Employee Engagement Survey',
      //   active: false,
      //   closeDate: DateTime.now().add(Duration(days: 45)),
      //   entriesCount: 200,
      //   logoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFe4BEwG37Mv0M724WYCTjsNP2UojEL3Oa0Q&s',
      // ),
      // Survey(
      //   id: '3',
      //   name: 'Market Research Survey',
      //   active: false,
      //   closeDate: DateTime.now().add(Duration(days: 60)),
      //   entriesCount: 300,
      //   logoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFe4BEwG37Mv0M724WYCTjsNP2UojEL3Oa0Q&s',
      // ),
    ];
    return surveys;
  }

  Future<Surveyor> getSurveyorProfile() async {
    // Implement API call
    return Surveyor(
      name: 'Luz Alvarez',
      role: 'Encuestador',
      avatarUrl: '',
      balance: 80.0,
      responses: 12,
      growthRate: 2.15,
    );
  }
}
