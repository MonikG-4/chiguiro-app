import 'package:dartz/dartz.dart';
import '../../../core/error/failures/failure.dart';

abstract class ISurveyRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchSurveys(int surveyorId);
  Future<Map<String, dynamic>> saveSurveyResults(Map<String, dynamic> entryInput);
}