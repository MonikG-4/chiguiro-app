import 'package:dartz/dartz.dart';
import '../../../core/error/failures/failure.dart';

import '../entities/survey.dart';
import '../entities/survey_responded.dart';
import '../entities/surveyor.dart';

abstract class IDashboardSurveyorRepository {
  Future<Either<Failure, bool>> changePassword(int pollsterId, String password);
  Future<Either<Failure, List<Survey>>> fetchSurveys(int surveyorId);
  Future<Either<Failure, Surveyor>> fetchDataSurveyor(int surveyorId);
  Future<Either<Failure, List<SurveyResponded>>> fetchSurveyResponded(String homeCode, int surveyorId);
}