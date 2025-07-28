abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class ConnectionFailure extends Failure {
  ConnectionFailure(super.message);
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message);
}
