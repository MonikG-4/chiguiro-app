import 'package:graphql_flutter/graphql_flutter.dart';

import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';

class SurveyProvider {
  final GraphQLClient client;

  SurveyProvider(this.client);

  Future<List<Survey>> getActiveSurveys() async {
    // Implement API call
    List<Survey> surveys = [
      Survey(
        id: '1',
        name: 'Customer Satisfaction Survey',
        organization: 'Acme Corp',
        closeDate: DateTime.now().add(Duration(days: 30)),
        responses: 0,
        logoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFe4BEwG37Mv0M724WYCTjsNP2UojEL3Oa0Q&s',
      ),
      Survey(
        id: '2',
        name: 'Employee Engagement Survey',
        organization: 'Tech Solutions',
        closeDate: DateTime.now().add(Duration(days: 45)),
        responses: 200,
        logoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFe4BEwG37Mv0M724WYCTjsNP2UojEL3Oa0Q&s',
      ),
      Survey(
        id: '3',
        name: 'Market Research Survey',
        organization: 'Market Insights',
        closeDate: DateTime.now().add(Duration(days: 60)),
        responses: 300,
        logoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFe4BEwG37Mv0M724WYCTjsNP2UojEL3Oa0Q&s',
      ),
    ];
    return surveys;
  }

  Future<List<Survey>> getHistoricalSurveys() async {
    // Implement API call
    return [];
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
