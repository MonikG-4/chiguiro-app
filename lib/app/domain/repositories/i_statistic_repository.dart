import 'package:dartz/dartz.dart';
import '../../../core/error/failures/failure.dart';

import '../entities/statistics.dart';

abstract class IStatisticRepository {
  Future<Either<Failure, Statistic>> fetchStatistics(int surveyorId);
}