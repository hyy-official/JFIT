import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:jfit/models/auth_token_response.dart';

class AuthService {
  // Singleton Pattern
  AuthService._internal() {
    _checkInitialStatus();
  }
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;

  static const String _tokenKey = 'auth_token_response';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  // 개발·테스트용 로컬 서버 URL
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  // 실제 프로덕션 배포 시에는 아래와 같이 도메인을 교체하세요.
  // static const String baseUrl = 'https://your-api-domain.com/api';

  // HTTP 클라이언트 설정
  static final http.Client _httpClient = http.Client();
  static const Duration _timeout = Duration(seconds: 30);

  // 인증 상태를 방송하는 StreamController
  final StreamController<bool> _authStatusController = StreamController<bool>.broadcast();
  Stream<bool> get authStatusStream => _authStatusController.stream;

  // 현재 사용자 정보
  TokenResponse? _tokenResponse;
  String? _currentToken;

  void dispose() {
    _authStatusController.close();
  }

  Future<void> _checkInitialStatus() async {
    final loggedIn = await isLoggedIn();
    _authStatusController.add(loggedIn);
  }

  // 토큰 정보 전체를 저장하고 로드
  Future<void> _saveAuthData(TokenResponse tokenResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, jsonEncode(tokenResponse.toJson()));
    _tokenResponse = tokenResponse;
    _authStatusController.add(true); // 로그인 상태 전파
  }

  Future<TokenResponse?> _loadAuthData() async {
    if (_tokenResponse != null) return _tokenResponse;
    
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_tokenKey);
    if (data != null) {
      _tokenResponse = TokenResponse.fromJson(jsonDecode(data) as Map<String, dynamic>);
      return _tokenResponse;
    }
    return null;
  }

  // 토큰 가져오기
  Future<String?> getToken() async {
    final data = await _loadAuthData();
    return data?.accessToken;
  }

  // 리프레시 토큰 가져오기
  Future<String?> getRefreshToken() async {
    final data = await _loadAuthData();
    return data?.refreshToken;
  }

  // 현재 사용자 정보 가져오기
  Future<User?> getCurrentUser() async {
    final data = await _loadAuthData();
    return data?.user;
  }

  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // 회원가입
  Future<TokenResponse> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        final tokenResponse = TokenResponse.fromJson(data);
        await _saveAuthData(tokenResponse);
        return tokenResponse;
      } else {
        throw AuthException(
          data['detail']?.toString() ?? 'Registration failed',
          response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw AuthException('Network connection failed: ${e.message}. Please check if the backend server is running on $baseUrl', 0);
    } on HttpException catch (e) {
      throw AuthException('HTTP error during registration: ${e.message}', 0);
    } on FormatException catch (e) {
      throw AuthException('Invalid response format: ${e.message}', 0);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error during registration: $e', 0);
    }
  }

  // 로그인
  Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email,
          'password': password,
        },
      ).timeout(_timeout);

      if (response.body.isEmpty) {
        throw AuthException('Login failed: Empty response from server', response.statusCode);
      }
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(data);
        await _saveAuthData(tokenResponse);
        return tokenResponse;
      } else {
        throw AuthException(
          data['detail']?.toString() ?? 'Login failed',
          response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw AuthException('Network connection failed: ${e.message}. Please check if the backend server is running on $baseUrl', 0);
    } on HttpException catch (e) {
      throw AuthException('HTTP error during login: ${e.message}', 0);
    } on FormatException catch (e) {
      throw AuthException('Invalid response format: ${e.message}', 0);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error during login: $e', 0);
    }
  }

  // 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(data);
        await _saveAuthData(tokenResponse);
        return true;
      } else {
        await logout(); // 리프레시 실패 시 로그아웃
        return false;
      }
    } catch (e) {
      await logout(); // 오류 발생 시 로그아웃
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final refreshToken = await getRefreshToken();
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'refresh_token': refreshToken})
        );
      }
    } catch (e) {
      // 서버 로그아웃 실패해도 로컬 데이터는 삭제
      print('Server logout failed: $e');
    } finally {
      await _clearAuthData();
    }
  }

  // 비밀번호 재설정 요청
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw AuthException(
          data['error']?['message'] ?? 'Password reset request failed',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error during password reset: $e', 0);
    }
  }

  // 비밀번호 재설정
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'password': newPassword,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw AuthException(
          data['error']?['message'] ?? 'Password reset failed',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error during password reset: $e', 0);
    }
  }

  // 계정 삭제
  Future<void> deleteAccount() async {
    try {
      final token = await getToken();
      if (token == null) throw AuthException('Not authenticated', 401);

      final response = await http.delete(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        await _clearAuthData();
      } else {
        throw AuthException(
          data['error']?['message'] ?? 'Account deletion failed',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error during account deletion: $e', 0);
    }
  }

  // 사용자 정보 업데이트
  Future<User?> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final token = await getToken();
      if (token == null) throw AuthException('Not authenticated', 401);

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // 로컬 사용자 정보 업데이트
        final updatedUser = <String, dynamic>{..._tokenResponse?.user?.toJson() ?? {}, ...Map<String, dynamic>.from(data['data'])};
        _tokenResponse = TokenResponse.fromJson(updatedUser);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(updatedUser));
        
        return _tokenResponse?.user;
      } else {
        throw AuthException(
          data['error']?['message'] ?? 'Profile update failed',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error during profile update: $e', 0);
    }
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    _tokenResponse = null;
    _authStatusController.add(false); // 로그아웃 상태 전파
  }

  // 토큰 유효성 검사
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // 토큰 만료, 리프레시 시도
        return await refreshToken();
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 자동 로그인 체크 (앱 시작 시 호출)
  Future<bool> checkAutoLogin() async {
    final isValid = await validateToken();
    if (!isValid) {
      await _clearAuthData();
    }
    return isValid;
  }
}

class AuthException implements Exception {
  final String message;
  final int statusCode;

  AuthException(this.message, this.statusCode);

  @override
  String toString() => 'AuthException: $message (Status: $statusCode)';
} 