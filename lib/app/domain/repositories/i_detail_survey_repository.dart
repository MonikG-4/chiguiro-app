import 'package:dartz/dartz.dart';
import '../../../core/error/failures/failure.dart';

import '../entities/detail_survey.dart';
import '../entities/survey_statistics.dart';

abstract class IDetailSurveyRepository {
  Future<Either<Failure, SurveyStatistics>> fetchStatisticsSurvey(int surveyorId, int surveyId);
  Future<Either<Failure, List<DetailSurvey>>> fetchSurveyDetail(int surveyorId, int surveyId, int pageIndex, int pageSize);
}