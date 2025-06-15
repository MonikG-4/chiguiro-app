import 'package:dartz/dartz.dart';
import '../../../core/error/failures/failure.dart';

abstract class IPendingSurveyRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchSurveys(int surveyorId);
}