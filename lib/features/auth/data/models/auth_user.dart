import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? fullName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
  });

  @override
  List<Object?> get props => [id, email, username, fullName];

  static const empty = AuthUser(id: 0, email: '', username: '');

  bool get isEmpty => this == AuthUser.empty;
  bool get isNotEmpty => this != AuthUser.empty;
}
