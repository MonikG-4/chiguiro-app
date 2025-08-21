abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class UnknownFailure extends Failure {
  UnknownFailure(super.message);
}