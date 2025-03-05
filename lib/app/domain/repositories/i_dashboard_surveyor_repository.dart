import '../entities/survey.dart';
import '../entities/surveyor.dart';

abstract class IDashboardSurveyorRepository {
  Future<bool> changePassword(int pollsterId, String password);

  Future<List<Survey>> fetchSurveys(int surveyorId);
  Future<Surveyor> fetchDataSurveyor(int surveyorId);
}
