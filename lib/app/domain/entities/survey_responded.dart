import 'survey.dart';

class SurveyResponded {
  final int totalEntries;
  final DateTime lastSurvey;
  final Survey survey;

  SurveyResponded({
    required this.totalEntries,
    required this.lastSurvey,
    required this.survey,
  });

  @override
  String toString() {
    return 'SurveyResponded(totalEntries: $totalEntries, lastSurvey: $lastSurvey, survey: $survey)';
  }
}
