abstract class RepositoryException implements Exception {
  final String message;
  final int? code;

  RepositoryException(this.message, [this.code]);

  @override
  String toString() => message;
}

class NetworkException extends RepositoryException {
  NetworkException(super.message, [super.code]);
}

class ServerException extends RepositoryException {
  ServerException(super.message, [super.code]);
}

class CacheException extends RepositoryException {
  CacheException(super.message, [super.code]);
}

class UnknownException extends RepositoryException {
  UnknownException(super.message, [super.code]);
}