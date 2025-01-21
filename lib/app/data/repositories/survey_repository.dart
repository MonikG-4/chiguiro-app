import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_survey_repository.dart';
import '../providers/survey_provider.dart';

class SurveyRepository implements ISurveyRepository {
  final SurveyProvider provider;

  SurveyRepository(this.provider);

  @override
  Future<List<Survey>> getActiveSurveys() => provider.getActiveSurveys();

  @override
  Future<List<Survey>> getHistoricalSurveys() => provider.getHistoricalSurveys();

  @override
  Future<Surveyor> getSurveyorProfile() => provider.getSurveyorProfile();
}