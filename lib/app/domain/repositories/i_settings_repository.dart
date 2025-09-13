import 'package:dartz/dartz.dart';
import '../../../core/error/failures/failure.dart';

abstract class ISettingsRepository {
  Future<Either<Failure, bool>> changePassword(int pollsterId, String password);
}