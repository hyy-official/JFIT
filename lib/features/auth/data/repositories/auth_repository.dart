import 'package:jfit/features/auth/data/models/auth_user.dart';

class AuthRepository {
  // 더미 사용자 데이터 (실제로는 DB에서 가져옴)
  final List<AuthUser> _users = [];

  AuthRepository();

  Future<AuthUser> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

    // TODO: 실제 백엔드 API 호출 및 비밀번호 해시 검증 로직 구현
    // 현재는 더미 데이터로 간단히 확인
    try {
      final user = _users.firstWhere(
        (u) => u.email == email && _verifyPassword(password, u.id), // 비밀번호 검증 로직 필요
      );
      // 로그인 성공 시 세션 토큰 저장 등 추가 로직
      return user;
    } catch (e) {
      throw Exception('Invalid email or password');
    }
  }

  Future<AuthUser> register(String email, String password, String username) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

    // TODO: 실제 백엔드 API 호출 및 비밀번호 해싱 후 DB 저장 로직 구현
    // 현재는 더미 데이터로 간단히 확인
    if (_users.any((u) => u.email == email || u.username == username)) {
      throw Exception('Email or username already in use');
    }

    final newUserId = _users.length + 1;
    final newUser = AuthUser(
      id: newUserId,
      email: email,
      username: username,
      // 실제로는 여기서 비밀번호를 해싱하여 저장해야 함
    );
    _users.add(newUser);
    // 회원가입 성공 시 자동 로그인 또는 추가 로직
    return newUser;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    // TODO: 세션 토큰 삭제 등 로그아웃 로직 구현
  }

  Future<AuthUser?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션
    // TODO: 저장된 세션 토큰을 기반으로 현재 사용자 정보 가져오는 로직 구현
    // 현재는 항상 null 반환 (로그인되지 않은 상태)
    return null;
  }

  // 더미 비밀번호 검증 (실제로는 해싱된 비밀번호와 비교)
  bool _verifyPassword(String plainPassword, int userId) {
    // 이 부분은 실제 백엔드에서 해싱된 비밀번호와 비교하는 로직이 되어야 합니다.
    // 여기서는 단순히 더미 사용자 ID에 따라 비밀번호를 'password'로 가정합니다.
    if (userId == 1 && plainPassword == 'password') return true;
    if (userId == 2 && plainPassword == 'password') return true;
    return false;
  }
}
