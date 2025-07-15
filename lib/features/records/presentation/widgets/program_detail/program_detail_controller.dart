import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';
import 'package:jfit/features/programs/data/models/workout_session_model.dart';

/// 프로그램 상세 화면의 비즈니스 로직을 담당하는 컨트롤러
class ProgramDetailController extends ChangeNotifier {
  // 상태 변수들
  int _selectedWeek = 1;
  int _selectedDay = 0;
  String? _selectedSessionId;
  bool _isInitialized = false;

  // 캐시 저장소
  final Map<String, WorkoutSessionModel> _sessionCache = {};
  final Map<String, List<dynamic>> _exerciseCache = {};
  List<UserProgramDayModel>? _cachedDays;
  List<WorkoutSessionModel>? _cachedSessions;

  // Getters
  int get selectedWeek => _selectedWeek;
  int get selectedDay => _selectedDay;
  String? get selectedSessionId => _selectedSessionId;
  bool get isInitialized => _isInitialized;

  /// 다음에 해야 할 운동 일차 찾기 (개선된 로직)
  void setNextWorkoutDay(Map<String, dynamic> programDetails, List<UserProgramDayModel> days) {
    if (_isInitialized) return; // 이미 초기화되었으면 건너뛰기
    
    // 모든 일차를 주차별로 정렬
    final sortedDays = days.toList()
      ..sort((a, b) {
        final weekCompare = a.week.compareTo(b.week);
        if (weekCompare != 0) return weekCompare;
        return a.day.compareTo(b.day);
      });
    
    // 완료되지 않은 첫 번째 일차 찾기
    UserProgramDayModel? nextDay;
    int nextDayIndex = 0;
    int nextWeek = 1;
    
    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      if (day.completedAt == null) {
        nextDay = day;
        nextWeek = day.week;
        
        // 해당 주차에서의 인덱스 찾기
        final weekDays = days.where((d) => d.week == nextWeek).toList()
          ..sort((a, b) => a.day.compareTo(b.day));
        nextDayIndex = weekDays.indexWhere((d) => d.day == day.day);
        break;
      }
    }
    
    // 완료되지 않은 일차가 없으면 마지막 주차의 마지막 일차 선택
    if (nextDay == null && sortedDays.isNotEmpty) {
      final lastDay = sortedDays.last;
      nextWeek = lastDay.week;
      final weekDays = days.where((d) => d.week == nextWeek).toList()
        ..sort((a, b) => a.day.compareTo(b.day));
      nextDayIndex = weekDays.length - 1;
    }
    
    _selectedWeek = nextWeek;
    _selectedDay = nextDayIndex;
    _isInitialized = true;
    notifyListeners();
    
    if (kDebugMode) {
      final status = nextDay?.completedAt != null ? '완료됨' : '미완료';
      print('🎯 다음 운동 일차 선택: Week $_selectedWeek, Day ${nextDayIndex + 1} ($status)');
    }
  }

  /// 선택된 일차가 완료되었는지 확인
  bool isSelectedDayCompleted(List<UserProgramDayModel> days) {
    final weekDays = days.where((d) => d.week == _selectedWeek).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    
    if (_selectedDay < weekDays.length) {
      final selectedDayObj = weekDays[_selectedDay];
      return selectedDayObj.completedAt != null;
    }
    return false;
  }

  /// 특정 일차가 완료되었는지 확인
  bool isDayCompleted(UserProgramDayModel day) {
    return day.completedAt != null;
  }

  /// 주차 선택
  void selectWeek(int week) {
    _selectedWeek = week;
    notifyListeners();
  }

  /// 일차 선택
  void selectDay(int dayIndex, List<UserProgramDayModel> weekDays, String userProgramId, List<WorkoutSessionModel> sessions) {
    _selectedDay = dayIndex;
    
    final selectedDayObj = weekDays.isNotEmpty && dayIndex < weekDays.length ? weekDays[dayIndex] : null;
    
    if (selectedDayObj != null) {
      // 캐시된 세션 확인
      final sessionKey = '${userProgramId}_day_${selectedDayObj.day}';
      if (_sessionCache.containsKey(sessionKey)) {
        _selectedSessionId = _sessionCache[sessionKey]!.id;
        notifyListeners();
        return; // 캐시된 데이터 사용, 추가 로딩 불필요
      }

      // 세션 찾기
      WorkoutSessionModel? session;
      if (sessions.isNotEmpty) {
        // day 번호에 맞는 세션 찾기 (1-based index를 0-based로 변환)
        final sessionIndex = selectedDayObj.day - 1;
        if (sessionIndex >= 0 && sessionIndex < sessions.length) {
          session = sessions[sessionIndex];
        } else {
          // 세션이 충분하지 않으면 첫 번째 세션 사용
          session = sessions.first;
        }
      }

      if (session != null) {
        _selectedSessionId = session.id;
        // 세션을 캐시에 저장
        _sessionCache[sessionKey] = session;
        // 운동 루틴도 캐시에 저장
        if (session.exercisesJson != null) {
          _exerciseCache[sessionKey] = session.exercisesJson!;
        }
      } else {
        _selectedSessionId = null;
      }
    }
    
    notifyListeners();
  }

  /// 표시할 운동 정보 가져오기 (캐시 우선)
  Future<List<dynamic>?> getExercisesForDisplay(String userProgramId, int week, int day) async {
    // 캐시된 데이터가 있는지 확인 (week 정보 포함)
    final sessionKey = '${userProgramId}_week_${week}_day_$day';
    if (_exerciseCache.containsKey(sessionKey)) {
      return _exerciseCache[sessionKey];
    }

    // 원본 프로그램 정보에서 운동 루틴 가져오기
    final exercises = await _getOriginalProgramExercises(userProgramId, week, day);
    
    // 캐시에 저장
    if (exercises != null) {
      _exerciseCache[sessionKey] = exercises;
    }
    
    return exercises;
  }

  /// 원본 프로그램 정보에서 운동 루틴 가져오기
  Future<List<dynamic>?> _getOriginalProgramExercises(String userProgramId, int week, int day) async {
    try {
      // user_programs 테이블에서 원본 exercises_json 가져오기
      final supabaseClient = Supabase.instance.client;
      final response = await supabaseClient
          .from('user_programs')
          .select('exercises_json')
          .eq('id', userProgramId)
          .single();

      final exercisesJson = response['exercises_json'] as List<dynamic>? ?? [];
      if (exercisesJson.isEmpty) return null;

      // 주차와 일차에 맞는 운동 정보 추출
      final weekIndex = week - 1;
      if (weekIndex < 0 || weekIndex >= exercisesJson.length) return null;

      final weekData = exercisesJson[weekIndex] as Map<String, dynamic>? ?? {};
      final days = weekData['days'] as List<dynamic>? ?? [];

      final dayIndex = day - 1;
      if (dayIndex < 0 || dayIndex >= days.length) return null;

      final dayData = days[dayIndex] as Map<String, dynamic>? ?? {};
      final exercises = dayData['exercises'] as List<dynamic>? ?? [];

      return exercises;
    } catch (e) {
      if (kDebugMode) {
        print('원본 프로그램 운동 정보 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// 캐시 정리
  void clearCache() {
    _sessionCache.clear();
    _exerciseCache.clear();
    _cachedDays = null;
    _cachedSessions = null;
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}