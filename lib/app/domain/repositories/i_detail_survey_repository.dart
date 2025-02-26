import '../entities/detail_survey.dart';

abstract class IDetailSurveyRepository {
  Future<List<DetailSurvey>> fetchSurveyDetail(
      int surveyorId, int pageIndex, int pageSize);
}
