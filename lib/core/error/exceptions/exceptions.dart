class CheckException implements Exception {
  final String message;
  CheckException(this.message);

  @override
  String toString() => message;
}

class GateException implements Exception {
  final String message;
  GateException(this.message);

  @override
  String toString() => message;
}

class GeneralException implements Exception {
  final String message;
  GeneralException(this.message);

  @override
  String toString() => message;
}

class AppNetworkException  implements Exception {
  final String message;
  AppNetworkException (this.message);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => message;
}

