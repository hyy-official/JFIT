import 'package:jfit/features/auth/data/models/auth_user.dart' as jfit_auth_user;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_lib;

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AuthRepository {
  final supabase_lib.SupabaseClient _supabaseClient;

  AuthRepository() : _supabaseClient = supabase_lib.Supabase.instance.client;

  Future<jfit_auth_user.AuthUser> login(String email, String password) async {
    try {
      // Supabase Auth 로그인 사용
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('로그인에 실패했습니다.');
      }

      final user = response.user!;
      
      // user_profiles 테이블에서 추가 정보 가져오기
      final profileResponse = await _supabaseClient
          .from('user_profiles')
          .select('username, full_name')
          .eq('id', user.id)
          .maybeSingle();

      return jfit_auth_user.AuthUser(
        id: user.id,
        email: user.email ?? '',
        username: profileResponse?['username'] ?? '',
        fullName: profileResponse?['full_name'],
      );
    } on supabase_lib.AuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.message));
    } catch (e) {
      throw AuthException('로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<jfit_auth_user.AuthUser> register(String email, String password, String username) async {
    try {
      // Supabase Auth 회원가입 사용
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('회원가입에 실패했습니다.');
      }

      final user = response.user!;

      // user_profiles 테이블에 추가 정보 저장
      await _supabaseClient.from('user_profiles').insert({
        'id': user.id,
        'username': username,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return jfit_auth_user.AuthUser(
        id: user.id,
        email: user.email ?? '',
        username: username,
        fullName: null,
      );
    } on supabase_lib.AuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.message));
    } catch (e) {
      throw AuthException('회원가입 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException('로그아웃 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<jfit_auth_user.AuthUser?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return null;
      }

      // user_profiles 테이블에서 추가 정보 가져오기
      final profileResponse = await _supabaseClient
          .from('user_profiles')
          .select('username, full_name')
          .eq('id', user.id)
          .maybeSingle();

      return jfit_auth_user.AuthUser(
        id: user.id,
        email: user.email ?? '',
        username: profileResponse?['username'] ?? '',
        fullName: profileResponse?['full_name'],
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // 인증 상태 변경 스트림
  Stream<jfit_auth_user.AuthUser?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      
      // 간단한 AuthUser 반환 (프로필 정보는 필요시 별도 로드)
      return jfit_auth_user.AuthUser(
        id: user.id,
        email: user.email ?? '',
        username: '', // 프로필에서 로드 필요
        fullName: null,
      );
    });
  }

  // Remember Me 기능 (Supabase가 자동으로 세션 관리)
  Future<void> setRememberMe(bool remember) async {
    // Supabase는 기본적으로 세션을 유지하므로 별도 구현 불필요
    // 필요시 로컬 스토리지에 설정 저장 가능
    print('Remember me: $remember (Supabase handles session automatically)');
  }

  // 비밀번호 재설정
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } on supabase_lib.AuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.message));
    } catch (e) {
      throw AuthException('비밀번호 재설정 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 이메일 확인
  Future<void> resendEmailConfirmation(String email) async {
    try {
      await _supabaseClient.auth.resend(
        type: supabase_lib.OtpType.signup,
        email: email,
      );
    } on supabase_lib.AuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.message));
    } catch (e) {
      throw AuthException('이메일 확인 재전송 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 에러 메시지 한국어 변환
  String _getAuthErrorMessage(String message) {
    switch (message.toLowerCase()) {
      case 'invalid login credentials':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'user already registered':
        return '이미 등록된 이메일입니다.';
      case 'weak password':
        return '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.';
      case 'invalid email':
        return '올바른 이메일 형식을 입력해주세요.';
      case 'signup disabled':
        return '현재 회원가입이 비활성화되어 있습니다.';
      case 'email not confirmed':
        return '이메일 인증을 완료해주세요.';
      case 'invalid argument(s): no host specified in uri /auth/v1/token?grant_type=password':
        return '서버 설정이 잘못되어 로그인할 수 없습니다.';
      default:
        return message;
    }
  }
}
