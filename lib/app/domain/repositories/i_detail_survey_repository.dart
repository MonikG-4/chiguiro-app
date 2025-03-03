import '../entities/detail_survey.dart';
import '../entities/survey_statistics.dart';

abstract class IDetailSurveyRepository {
  Future<SurveyStatistics> fetchStatisticsSurvey(int surveyorId, int surveyId);
  Future<List<DetailSurvey>> fetchSurveyDetail(
      int surveyorId, int surveyId, int pageIndex, int pageSize);
}
