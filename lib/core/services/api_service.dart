import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  // static const String baseUrl = 'https://your-api-domain.com/api';

  // HTTP 클라이언트 설정
  static final http.Client _httpClient = http.Client();

  Future<Map<String, String>> get _headers async {
    // TODO: 필요시 인증 토큰 추가
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // HTTP 요청 헬퍼
  Future<dynamic> _makeRequest(
      String method, String path, {Map<String, dynamic>? queryParams, Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final headers = await _headers;

    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _httpClient.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _httpClient.post(uri, headers: headers, body: json.encode(body));
          break;
        case 'PUT':
          response = await _httpClient.put(uri, headers: headers, body: json.encode(body));
          break;
        case 'DELETE':
          response = await _httpClient.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('API request failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      rethrow; // 예외를 다시 던져서 호출하는 곳에서 처리하도록 함
    }
  }

  // Workout Programs
  Future<List<Map<String, dynamic>>> getWorkoutPrograms({
    String? search,
    String? difficulty,
    String? programType,
    int? durationWeeks,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null) queryParams['search'] = search;
    if (difficulty != null) queryParams['difficulty'] = difficulty;
    if (programType != null) queryParams['program_type'] = programType;
    if (durationWeeks != null) queryParams['duration_weeks'] = durationWeeks.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _makeRequest('GET', '/programs', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getWorkoutProgram(String id) async {
    final response = await _makeRequest('GET', '/programs/$id');
    return Map<String, dynamic>.from(response);
  }

  Future<void> rateWorkoutProgram(String programId, double rating, {String? review}) async {
    await _makeRequest('POST', '/programs/$programId/rate', body: {
      'rating': rating,
      if (review != null) 'review': review,
    });
  }

  Future<void> favoriteWorkoutProgram(String programId) async {
    await _makeRequest('POST', '/programs/$programId/favorite');
  }

  // Exercises
  Future<List<Map<String, dynamic>>> getExercises({
    String? search,
    String? type,
    String? muscleGroup,
    String? equipment,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null) queryParams['search'] = search;
    if (type != null) queryParams['type'] = type;
    if (muscleGroup != null) queryParams['muscle_group'] = muscleGroup;
    if (equipment != null) queryParams['equipment'] = equipment;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _makeRequest('GET', '/exercises', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createExercise(Map<String, dynamic> exerciseData) async {
    final response = await _makeRequest('POST', '/exercises', body: exerciseData);
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getExerciseStats() async {
    final response = await _makeRequest('GET', '/exercises/stats');
    return Map<String, dynamic>.from(response);
  }

  // Food Items
  Future<List<Map<String, dynamic>>> getFoodItems({String? search, String? category, int? limit, int? offset}) async {
    final queryParams = <String, dynamic>{};
    if (search != null) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _makeRequest('GET', '/foods', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createFoodItem(Map<String, dynamic> foodData) async {
    final response = await _makeRequest('POST', '/foods', body: foodData);
    return Map<String, dynamic>.from(response);
  }

  // Meal Entries
  Future<List<Map<String, dynamic>>> getMeals({String? mealType, String? date, int? limit, int? offset}) async {
    final queryParams = <String, dynamic>{};
    if (mealType != null) queryParams['meal_type'] = mealType;
    if (date != null) queryParams['date'] = date;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _makeRequest('GET', '/meals', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createMeal(Map<String, dynamic> mealData) async {
    final response = await _makeRequest('POST', '/meals', body: mealData);
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getMealStats() async {
    final response = await _makeRequest('GET', '/meals/stats');
    return Map<String, dynamic>.from(response);
  }

  // Workout Sessions
  Future<List<Map<String, dynamic>>> getWorkoutSessions() async {
    final response = await _makeRequest('GET', '/sessions');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createWorkoutSession(Map<String, dynamic> sessionData) async {
    final response = await _makeRequest('POST', '/sessions', body: sessionData);
    return Map<String, dynamic>.from(response);
  }

  Future<void> completeWorkoutSession(String id, Map<String, dynamic> completionData) async {
    await _makeRequest('POST', '/sessions/$id/complete', body: completionData);
  }

  // Sync
  Future<Map<String, dynamic>> getChanges({required DateTime since, int? limit}) async {
    final queryParams = <String, dynamic>{
      'since': since.toIso8601String(),
    };
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _makeRequest('GET', '/sync/changes', queryParams: queryParams);
    return Map<String, dynamic>.from(response);
  }

  Future<void> pushChanges(List<Map<String, dynamic>> changes) async {
    await _makeRequest('POST', '/sync/push', body: {
      'changes': changes,
    });
  }

  Future<void> resolveConflicts(List<Map<String, dynamic>> conflicts) async {
    await _makeRequest('POST', '/sync/resolve-conflicts', body: {
      'conflicts': conflicts,
    });
  }

  // Stats
  Future<Map<String, dynamic>> getDashboardStats({required String period}) async {
    final response = await _makeRequest('POST', '/stats/dashboard', body: {
      'period': period,
    });
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getProgressStats({
    String? exerciseId,
    String? period,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (exerciseId != null) queryParams['exercise_id'] = exerciseId;
    if (period != null) queryParams['period'] = period;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _makeRequest('GET', '/stats/progress', queryParams: queryParams);
    return Map<String, dynamic>.from(response);
  }

  // User Profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _makeRequest('GET', '/profile');
    return Map<String, dynamic>.from(response);
  }

  // --- Analytics API Calls ---
  Future<List<Map<String, dynamic>>> getDietScoreData(String period) async {
    // Supabase PostgREST API를 직접 호출하는 로직으로 변경
    // 예시: Supabase.instance.client.from('user_meal_entries').select('entry_date, calories, protein, carbohydrates, fat')...
    // 이 부분은 Supabase 클라이언트 라이브러리를 사용하여 구현해야 합니다.
    // 현재 ApiService는 http 패키지를 사용하므로, Supabase 클라이언트와 연동하는 로직이 필요합니다.
    // 일단은 빈 리스트를 반환하도록 하겠습니다.
    return [];
  }

  Future<List<Map<String, dynamic>>> getNutritionData(String period) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getWorkoutTimeData(String period) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getWorkoutCompositionData(String period) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getBodyData(String period) async {
    return [];
  }
}