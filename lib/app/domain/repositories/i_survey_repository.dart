import 'package:dartz/dartz.dart';
import '../../../core/error/failures/failure.dart';
import '../entities/block_code.dart';

abstract class ISurveyRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchSurveys(int surveyorId);
  Future<Map<String, dynamic>> saveSurveyResults(Map<String, dynamic> entryInput);
  Future<Either<Failure, BlockCode>> fecthBlockCode(double latitude, double longitude);

}