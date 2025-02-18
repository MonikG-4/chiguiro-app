import '../entities/sections.dart';

abstract class ISurveyRepository {
  Future<List<Sections>> fetchSurveyQuestions(int surveyId);
  Future<bool> saveSurveyResults(Map<String, dynamic> entryInput);
}
