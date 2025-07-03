part of 'auth_bloc.dart';

abstract class AuthState with EquatableMixin {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final int userId;
  final String username;

  const AuthAuthenticated({required this.userId, required this.username});

  @override
  List<Object?> get props => [userId, username];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}