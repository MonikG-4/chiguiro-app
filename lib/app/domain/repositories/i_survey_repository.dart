import '../entities/sections.dart';

abstract class ISurveyRepository {
  Future<List<Sections>> fetchSurveyQuestions(int surveyId);
  Future<void> saveSurveyResults(Map<String, dynamic> entryInput, String token);
}
