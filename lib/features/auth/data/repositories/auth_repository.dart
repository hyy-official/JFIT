import 'package:jfit/features/auth/data/models/auth_user.dart' as jfit_auth_user;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_lib;

class AuthRepository {
  final supabase_lib.SupabaseClient _supabaseClient;

  AuthRepository() : _supabaseClient = supabase_lib.Supabase.instance.client;

  Future<jfit_auth_user.AuthUser> login(String email, String password) async {
    // TODO: 실제 프로덕션 환경에서는 비밀번호 검증을 안전한 백엔드 API를 통해 수행해야 합니다.
    // 클라이언트에서 직접 비밀번호를 해싱하거나 검증하는 것은 보안상 매우 위험합니다.
    try {
      final response = await _supabaseClient
          .from('users')
          .select('id, email, username, full_name, hashed_password')
          .eq('email', email)
          .single();

      final storedHashedPassword = response['hashed_password'] as String;
      // TODO: 여기서는 더미로 비밀번호가 일치하는지 확인합니다.
      // 실제로는 백엔드에서 plain password와 storedHashedPassword를 비교해야 합니다.
      if (password != storedHashedPassword) { // 이 부분은 백엔드에서 처리되어야 함
        throw Exception('Invalid email or password');
      }

      return jfit_auth_user.AuthUser(
        id: response['id'] as int,
        email: response['email'] as String,
        username: response['username'] as String,
        fullName: response['full_name'] as String?,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<jfit_auth_user.AuthUser> register(String email, String password, String username) async {
    // TODO: 실제 프로덕션 환경에서는 비밀번호 해싱을 안전한 백엔드 API를 통해 수행해야 합니다.
    // 클라이언트에서 직접 비밀번호를 해싱하는 것은 보안상 매우 위험합니다.
    try {
      // 비밀번호를 해싱하여 저장 (여기서는 더미로 평문 저장)
      final hashedPassword = password; // 실제로는 bcrypt 등으로 해싱된 값

      final response = await _supabaseClient.from('users').insert({
        'email': email,
        'username': username,
        'hashed_password': hashedPassword,
        'is_active': true,
        'is_verified': false, // 이메일 인증 필요 시 false
      }).select().single();

      return jfit_auth_user.AuthUser(
        id: response['id'] as int,
        email: response['email'] as String,
        username: response['username'] as String,
        fullName: response['full_name'] as String?,
      );
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    // TODO: 세션 관리 로직 구현 (예: 로컬 저장소에서 토큰 삭제)
    // 자체 인증 시스템이므로 Supabase Auth의 signOut은 사용하지 않습니다.
    print('User logged out (dummy)');
  }

  Future<jfit_auth_user.AuthUser?> getCurrentUser() async {
    // TODO: 저장된 세션 토큰을 기반으로 현재 사용자 정보 가져오는 로직 구현
    // 예를 들어, 로컬 저장소에 저장된 사용자 ID나 토큰을 확인하여 DB에서 사용자 정보를 조회합니다.
    // 현재는 항상 null 반환 (로그인되지 않은 상태)
    return null;
  }
}
