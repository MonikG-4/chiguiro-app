import 'package:dartz/dartz.dart';
import '../../../core/error/failures/failure.dart';

import '../entities/auth_response.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthResponse>> login(String email, String password);
  Future<Either<Failure, bool>> forgotPassword(String email);
}