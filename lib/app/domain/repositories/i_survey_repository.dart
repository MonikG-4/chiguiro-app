import '../entities/survey.dart';
import '../entities/surveyor.dart';

abstract class ISurveyRepository {
  Future<List<Survey>> getActiveSurveys();
  Future<List<Survey>> getHistoricalSurveys();
  Future<Surveyor> getSurveyorProfile();
}