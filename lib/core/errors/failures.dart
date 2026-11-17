import 'package:equatable/equatable.dart';

/// Base class representing failure domain objects handled by BLoCs.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Represents failure responses returned by the remote API.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents failures caused by network timeouts or missing connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection unavailable']);
}

/// Represents failures caused by local storage or cache reads/writes.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache access failed']);
}

/// Represents business logic or input validation rejections.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
