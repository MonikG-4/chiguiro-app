import '../entities/survey_question.dart';

abstract class ISurveyRepository {
  Future<List<SurveyQuestion>> fetchSurveyQuestions(int surveyId);
}
