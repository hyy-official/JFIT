import 'package:equatable/equatable.dart';

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