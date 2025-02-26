import '../entities/sections.dart';
import '../entities/survey.dart';
import '../entities/surveyor.dart';

abstract class IDashboardSurveyorRepository {
  Future<Survey> fetchActiveSurveys(int surveyId);
  Future<List<Survey>> getHistoricalSurveys();
  Future<Surveyor> getSurveyorProfile(int surveyorId);

  Future<List<Sections>> fetchSurveyQuestions(int surveyId);

}
