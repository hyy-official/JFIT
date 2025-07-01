import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jfit/core/services/auth_service.dart';

class ApiService {
  // 개발·테스트용 로컬 서버 URL
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  // 실제 프로덕션 배포 시에는 아래와 같이 도메인을 교체하세요.
  // static const String baseUrl = 'https://your-api-domain.com/api';
  
  final AuthService _authService = AuthService();

  // 인증 헤더 생성
  Future<Map<String, String>> get _headers async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // HTTP 요청 헬퍼
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final headers = await _headers;
      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          data['error']?['message'] ?? 'Unknown error',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  // 운동 프로그램 API
  Future<List<Map<String, dynamic>>> getWorkoutPrograms({
    int page = 1,
    int limit = 20,
    String? difficulty,
    String? type,
    String? search,
    bool? popular,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (difficulty != null) 'difficulty': difficulty,
      if (type != null) 'type': type,
      if (search != null) 'search': search,
      if (popular != null) 'popular': popular.toString(),
    };

    final response = await _makeRequest('GET', '/programs', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> getWorkoutProgram(String id) async {
    final response = await _makeRequest('GET', '/programs/$id');
    return response['data'] ?? {};
  }

  Future<void> rateProgram(String programId, int rating, String? review) async {
    await _makeRequest('POST', '/programs/$programId/rate', body: {
      'rating': rating,
      if (review != null) 'review': review,
    });
  }

  Future<void> toggleProgramFavorite(String programId) async {
    await _makeRequest('POST', '/programs/$programId/favorite');
  }

  // 운동 기록 API
  Future<List<Map<String, dynamic>>> getExercises({
    String? dateFrom,
    String? dateTo,
    String? exerciseType,
    int? limit,
  }) async {
    final queryParams = <String, String>{
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (exerciseType != null) 'exercise_type': exerciseType,
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _makeRequest('GET', '/exercises', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> createExercise(Map<String, dynamic> exerciseData) async {
    final response = await _makeRequest('POST', '/exercises', body: exerciseData);
    return response['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateExercise(String id, Map<String, dynamic> exerciseData) async {
    final response = await _makeRequest('PUT', '/exercises/$id', body: exerciseData);
    return response['data'] ?? {};
  }

  Future<void> deleteExercise(String id) async {
    await _makeRequest('DELETE', '/exercises/$id');
  }

  Future<Map<String, dynamic>> getExerciseStats() async {
    final response = await _makeRequest('GET', '/exercises/stats');
    return response['data'] ?? {};
  }

  // 음식 및 식사 기록 API
  Future<List<Map<String, dynamic>>> searchFoods({
    String? search,
    String? barcode,
    String? category,
    int? limit,
  }) async {
    final queryParams = <String, String>{
      if (search != null) 'search': search,
      if (barcode != null) 'barcode': barcode,
      if (category != null) 'category': category,
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _makeRequest('GET', '/foods', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> createFood(Map<String, dynamic> foodData) async {
    final response = await _makeRequest('POST', '/foods', body: foodData);
    return response['data'] ?? {};
  }

  Future<List<Map<String, dynamic>>> getMeals({
    String? dateFrom,
    String? dateTo,
    String? mealType,
  }) async {
    final queryParams = <String, String>{
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (mealType != null) 'meal_type': mealType,
    };

    final response = await _makeRequest('GET', '/meals', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> createMeal(Map<String, dynamic> mealData) async {
    final response = await _makeRequest('POST', '/meals', body: mealData);
    return response['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateMeal(String id, Map<String, dynamic> mealData) async {
    final response = await _makeRequest('PUT', '/meals/$id', body: mealData);
    return response['data'] ?? {};
  }

  Future<void> deleteMeal(String id) async {
    await _makeRequest('DELETE', '/meals/$id');
  }

  Future<Map<String, dynamic>> getMealStats() async {
    final response = await _makeRequest('GET', '/meals/stats');
    return response['data'] ?? {};
  }

  // 운동 세션 API
  Future<List<Map<String, dynamic>>> getWorkoutSessions() async {
    final response = await _makeRequest('GET', '/sessions');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> createWorkoutSession(Map<String, dynamic> sessionData) async {
    final response = await _makeRequest('POST', '/sessions', body: sessionData);
    return response['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateWorkoutSession(String id, Map<String, dynamic> sessionData) async {
    final response = await _makeRequest('PUT', '/sessions/$id', body: sessionData);
    return response['data'] ?? {};
  }

  Future<void> completeWorkoutSession(String id, Map<String, dynamic> completionData) async {
    await _makeRequest('POST', '/sessions/$id/complete', body: completionData);
  }

  // 동기화 API
  Future<Map<String, dynamic>> getChanges({
    required String since,
    List<String>? tables,
  }) async {
    final queryParams = <String, String>{
      'since': since,
      if (tables != null) 'tables': tables.join(','),
    };

    final response = await _makeRequest('GET', '/sync/changes', queryParams: queryParams);
    return response['data'] ?? {};
  }

  Future<Map<String, dynamic>> pushChanges(List<Map<String, dynamic>> changes) async {
    final response = await _makeRequest('POST', '/sync/push', body: {
      'changes': changes,
    });
    return response['data'] ?? {};
  }

  Future<void> resolveConflicts(List<Map<String, dynamic>> conflicts) async {
    await _makeRequest('POST', '/sync/resolve-conflicts', body: {
      'conflicts': conflicts,
    });
  }

  // 통계 API
  Future<Map<String, dynamic>> getDashboardStats({
    String timeframe = 'week',
    String timezone = 'Asia/Seoul',
  }) async {
    final response = await _makeRequest('POST', '/stats/dashboard', body: {
      'timeframe': timeframe,
      'timezone': timezone,
    });
    return response['data'] ?? {};
  }

  Future<Map<String, dynamic>> getProgressStats({
    required String metric,
    String period = '30d',
  }) async {
    final queryParams = <String, String>{
      'metric': metric,
      'period': period,
    };

    final response = await _makeRequest('GET', '/stats/progress', queryParams: queryParams);
    return response['data'] ?? {};
  }

  // 사용자 프로필 API
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _makeRequest('GET', '/profile');
    return response['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    final response = await _makeRequest('PUT', '/profile', body: profileData);
    return response['data'] ?? {};
  }

  Future<void> deleteProfile() async {
    await _makeRequest('DELETE', '/profile');
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
} 