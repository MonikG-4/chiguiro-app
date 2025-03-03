import '../entities/sections.dart';
import '../entities/survey.dart';
import '../entities/surveyor.dart';

abstract class IDashboardSurveyorRepository {
  Future<bool> changePassword(int pollsterId, String password);

  Future<List<Survey>> fetchActiveSurveys(int surveyorId);
  Future<List<Survey>> getHistoricalSurveys();
  Future<Surveyor> getSurveyorProfile(int surveyorId);
}
