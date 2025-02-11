import '../entities/survey.dart';
import '../entities/surveyor.dart';

abstract class IDashboardSurveyorRepository {
  Future<List<Survey>> getActiveSurveys(int projectId);
  Future<List<Survey>> getHistoricalSurveys();
  Future<Surveyor> getSurveyorProfile();
}
