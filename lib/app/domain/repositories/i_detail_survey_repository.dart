import '../entities/detail_survey.dart';

abstract class IDetailSurveyRepository {
  Future<List<DetailSurvey>> getSurveyDetail(
      int surveyId, int pageIndex, int pageSize);
}
