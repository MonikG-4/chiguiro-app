import '../entities/detail_survey.dart';

abstract class IDetailSurveyRepository {
  Future<List<DetailSurvey>> fetchSurveyDetail(
      int surveyId, int pageIndex, int pageSize);
}
