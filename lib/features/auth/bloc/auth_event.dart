import 'package:equatable/equatable.dart';
import 'package:jfit/features/auth/data/models/auth_user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object?> get props => [email, password, username];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthUserChanged extends AuthEvent {
  final AuthUser? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthResendEmailConfirmationRequested extends AuthEvent {
  final String email;

  const AuthResendEmailConfirmationRequested(this.email);

  @override
  List<Object?> get props => [email];
}