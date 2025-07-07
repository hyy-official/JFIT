import 'package:equatable/equatable.dart';

class AuthUser {
  final String id;
  final String email;
  final String username;
  final String? fullName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: map['id']?.toString() ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      fullName: map['full_name'],
    );
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
    );
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email, username: $username, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.fullName == fullName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        (fullName?.hashCode ?? 0);
  }
}
