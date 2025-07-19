import 'package:equatable/equatable.dart';

// Export workout program specific failures
export 'workout_program_failures.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Database Failure
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

// Auth Failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// General Failure
class GeneralFailure extends Failure {
  const GeneralFailure(super.message);
}

// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Permission Failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

// Not Found Failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
} 