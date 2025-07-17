import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/models/exercise.dart';
import 'package:jfit/core/utils/workout_program_logger.dart';
import 'package:jfit/core/error/workout_program_failures.dart';

/// 운동 데이터 파싱을 위한 유틸리티 클래스
/// exercises_json 필드의 다양한 형식을 안전하게 처리합니다.
class ExerciseDataParser {
  /// exercises_json 데이터를 안전하게 파싱하여 Exercise 리스트로 변환
  /// 
  /// 지원하는 형식:
  /// - JSON 문자열 (String)
  /// - 직접 리스트 (List<dynamic>)
  /// - 중첩된 주차/일차 구조 (Map<String, dynamic>)
  /// - null 또는 빈 데이터
  static Either<Failure, List<Exercise>> parseExercises(dynamic exercisesData) {
    const operationId = 'parse_exercises';
    WorkoutProgramLogger.startPerformanceTimer(operationId);
    
    try {
      // 데이터 형식 감지 및 로깅
      final detectedFormat = detectDataFormat(exercisesData);
      
      WorkoutProgramLogger.logDataParsing(
        'exercise_data_parsing_start',
        exercisesData,
        detectedFormat: detectedFormat,
      );

      if (exercisesData == null) {
        final duration = WorkoutProgramLogger.endPerformanceTimer(operationId);
        WorkoutProgramLogger.logDataParsing(
          'exercise_data_parsing_complete',
          exercisesData,
          detectedFormat: detectedFormat,
          resultCount: 0,
          duration: duration,
        );
        return const Right([]);
      }

      List<dynamic> exerciseList = [];

      // 1. JSON 문자열 형식 처리
      if (exercisesData is String) {
        if (exercisesData.trim().isEmpty) {
          final duration = WorkoutProgramLogger.endPerformanceTimer(operationId);
          WorkoutProgramLogger.logDataParsing(
            'exercise_data_parsing_complete',
            exercisesData,
            detectedFormat: detectedFormat,
            resultCount: 0,
            duration: duration,
          );
          return const Right([]);
        }
        
        try {
          final decoded = jsonDecode(exercisesData);
          exerciseList = _extractExerciseList(decoded);
        } catch (e) {
          final duration = WorkoutProgramLogger.endPerformanceTimer(operationId);
          final failure = DataParsingFailure(
            message: 'JSON 문자열 파싱 실패: $e',
            dataType: 'exercises_json_string',
            technicalMessage: 'Failed to decode JSON string: $exercisesData',
          );
          
          WorkoutProgramLogger.logDataParsing(
            'exercise_data_parsing_failed',
            exercisesData,
            detectedFormat: detectedFormat,
            duration: duration,
            error: failure.message,
          );
          
          return Left(failure);
        }
      }
      // 2. 직접 리스트 형식 처리
      else if (exercisesData is List) {
        exerciseList = exercisesData;
      }
      // 3. 맵 형식 (중첩 구조) 처리
      else if (exercisesData is Map<String, dynamic>) {
        exerciseList = _extractExerciseList(exercisesData);
      }
      // 4. 지원하지 않는 형식
      else {
        final duration = WorkoutProgramLogger.endPerformanceTimer(operationId);
        final failure = DataParsingFailure(
          message: '지원하지 않는 운동 데이터 형식입니다.',
          dataType: exercisesData.runtimeType.toString(),
          technicalMessage: 'Unsupported exercises data format: ${exercisesData.runtimeType}',
        );
        
        WorkoutProgramLogger.logDataParsing(
          'exercise_data_parsing_failed',
          exercisesData,
          detectedFormat: detectedFormat,
          duration: duration,
          error: failure.message,
        );
        
        return Left(failure);
      }

      // 운동 리스트 검증 및 변환
      final result = _validateAndConvertExercises(exerciseList);
      final duration = WorkoutProgramLogger.endPerformanceTimer(operationId, threshold: 100);
      
      result.fold(
        (failure) => WorkoutProgramLogger.logDataParsing(
          'exercise_data_parsing_failed',
          exercisesData,
          detectedFormat: detectedFormat,
          duration: duration,
          error: failure.message,
        ),
        (exercises) => WorkoutProgramLogger.logDataParsing(
          'exercise_data_parsing_complete',
          exercisesData,
          detectedFormat: detectedFormat,
          resultCount: exercises.length,
          duration: duration,
        ),
      );
      
      return result;
      
    } catch (e) {
      final duration = WorkoutProgramLogger.endPerformanceTimer(operationId);
      final failure = DataParsingFailure(
        message: '운동 데이터 파싱 중 예상치 못한 오류가 발생했습니다.',
        dataType: 'exercises_json',
        technicalMessage: 'Unexpected error during exercise parsing: $e',
      );
      
      WorkoutProgramLogger.logDataParsing(
        'exercise_data_parsing_failed',
        exercisesData,
        duration: duration,
        error: failure.message,
      );
      
      return Left(failure);
    }
  }

  /// 특정 주차와 일차의 운동 데이터를 파싱
  static Either<Failure, List<Exercise>> parseExercisesForWeekDay(
    dynamic exercisesData, 
    int week, 
    int day
  ) {
    final operationId = 'parse_exercises_week_day_${week}_$day';
    WorkoutProgramLogger.startPerformanceTimer(operationId);
    
    try {
      // 데이터 형식 감지 및 로깅
      final detectedFormat = detectDataFormat(exercisesData);
      
      WorkoutProgramLogger.logDataParsing(
        'exercise_week_day_parsing_start',
        exercisesData,
        detectedFormat: detectedFormat,
      );

      if (exercisesData == null) {
        final duration = WorkoutProgramLogger.endPerformanceTimer(operationId);
        WorkoutProgramLogger.logDataParsing(
          'exercise_week_day_parsing_complete',
          exercisesData,
          detectedFormat: detectedFormat,
          resultCount: 0,
          duration: duration,
        );
        return const Right([]);
      }

      List<dynamic> exerciseList = [];

      // JSON 문자열인 경우 먼저 디코드
      dynamic data = exercisesData;
      if (exercisesData is String) {
        if (exercisesData.trim().isEmpty) {
          final duration = WorkoutProgramLogger.endPerformanceTimer(operationId);
          WorkoutProgramLogger.logDataParsing(
            'exercise_week_day_parsing_complete',
            exercisesData,
            detectedFormat: detectedFormat,
            resultCount: 0,
            duration: duration,
          );
          return const Right([]);
        }
        
        try {
          data = jsonDecode(exercisesData);
        } catch (e) {
          final duration = WorkoutProgramLogger.endPerformanceTimer(operationId);
          final failure = DataParsingFailure(
            message: 'JSON 문자열 파싱 실패: $e',
            dataType: 'exercises_json_string',
            technicalMessage: 'Failed to decode JSON string for week $week day $day',
          );
          
          WorkoutProgramLogger.logDataParsing(
            'exercise_week_day_parsing_failed',
            exercisesData,
            detectedFormat: detectedFormat,
            duration: duration,
            error: failure.message,
          );
          
          return Left(failure);
        }
      }

      // 주차/일차 구조에서 특정 운동 추출
      if (data is List) {
        // 주차 배열 구조: [week1, week2, ...]
        final weekIndex = week - 1;
        if (weekIndex >= 0 && weekIndex < data.length) {
          final weekData = data[weekIndex];
          if (weekData is Map<String, dynamic>) {
            final days = weekData['days'] as List<dynamic>? ?? [];
            final dayIndex = day - 1;
            if (dayIndex >= 0 && dayIndex < days.length) {
              final dayData = days[dayIndex];
              if (dayData is Map<String, dynamic>) {
                exerciseList = dayData['exercises'] as List<dynamic>? ?? [];
              }
            }
          }
        }
      } else if (data is Map<String, dynamic>) {
        // 맵 구조에서 주차/일차 키로 접근
        final weekKey = 'week_$week';
        if (data.containsKey(weekKey)) {
          final weekData = data[weekKey] as Map<String, dynamic>?;
          if (weekData != null) {
            final dayKey = 'day_$day';
            if (weekData.containsKey(dayKey)) {
              final dayData = weekData[dayKey];
              if (dayData is List) {
                exerciseList = dayData;
              } else if (dayData is Map<String, dynamic>) {
                exerciseList = dayData['exercises'] as List<dynamic>? ?? [];
              }
            }
          }
        }
      }

      final result = _validateAndConvertExercises(exerciseList);
      final duration = WorkoutProgramLogger.endPerformanceTimer(operationId, threshold: 50);
      
      result.fold(
        (failure) => WorkoutProgramLogger.logDataParsing(
          'exercise_week_day_parsing_failed',
          exercisesData,
          detectedFormat: detectedFormat,
          duration: duration,
          error: failure.message,
        ),
        (exercises) => WorkoutProgramLogger.logDataParsing(
          'exercise_week_day_parsing_complete',
          exercisesData,
          detectedFormat: detectedFormat,
          resultCount: exercises.length,
          duration: duration,
        ),
      );
      
      return result;
      
    } catch (e) {
      final duration = WorkoutProgramLogger.endPerformanceTimer(operationId);
      final failure = DataParsingFailure(
        message: '주차 $week, 일차 $day 운동 데이터 파싱 실패',
        dataType: 'exercises_json_week_day',
        technicalMessage: 'Failed to parse exercises for week $week day $day: $e',
      );
      
      WorkoutProgramLogger.logDataParsing(
        'exercise_week_day_parsing_failed',
        exercisesData,
        duration: duration,
        error: failure.message,
      );
      
      return Left(failure);
    }
  }

  /// 중첩된 데이터 구조에서 운동 리스트 추출
  static List<dynamic> _extractExerciseList(dynamic data) {
    if (data is List) {
      return data;
    }
    
    if (data is Map<String, dynamic>) {
      // exercises 키가 있는 경우
      if (data.containsKey('exercises')) {
        final exercises = data['exercises'];
        if (exercises is List) {
          return exercises;
        }
      }
      
      // 첫 번째 주차의 첫 번째 일차 운동을 기본값으로 사용
      for (final key in data.keys) {
        if (key.startsWith('week_')) {
          final weekData = data[key];
          if (weekData is Map<String, dynamic>) {
            for (final dayKey in weekData.keys) {
              if (dayKey.startsWith('day_')) {
                final dayData = weekData[dayKey];
                if (dayData is List) {
                  return dayData;
                } else if (dayData is Map<String, dynamic>) {
                  final exercises = dayData['exercises'];
                  if (exercises is List) {
                    return exercises;
                  }
                }
              }
            }
          }
        }
      }
    }
    
    return [];
  }

  /// 운동 리스트 검증 및 Exercise 객체로 변환
  static Either<Failure, List<Exercise>> _validateAndConvertExercises(List<dynamic> exerciseList) {
    if (exerciseList.isEmpty) {
      return const Right([]);
    }

    try {
      final List<Exercise> exercises = [];
      
      for (int i = 0; i < exerciseList.length; i++) {
        final exerciseData = exerciseList[i];
        
        if (exerciseData == null) {
          continue; // null 항목은 건너뛰기
        }
        
        if (exerciseData is! Map<String, dynamic>) {
          return Left(DataParsingFailure(
            message: '운동 데이터가 올바른 형식이 아닙니다.',
            dataType: 'exercise_item',
            technicalMessage: 'Exercise item at index $i is not a Map: ${exerciseData.runtimeType}',
          ));
        }

        try {
          // Exercise 객체 생성 시도
          final exercise = _createExerciseFromMap(exerciseData);
          exercises.add(exercise);
        } catch (e) {
          // 개별 운동 파싱 실패 시 로그만 남기고 계속 진행
          print('운동 데이터 파싱 실패 (인덱스 $i): $e');
          continue;
        }
      }

      return Right(exercises);
      
    } catch (e) {
      return Left(DataParsingFailure(
        message: '운동 리스트 검증 실패',
        dataType: 'exercise_list',
        technicalMessage: 'Failed to validate exercise list: $e',
      ));
    }
  }

  /// Map 데이터에서 Exercise 객체 생성
  static Exercise _createExerciseFromMap(Map<String, dynamic> data) {
    // 필수 필드 기본값 설정
    final id = _parseIntSafely(data['id'] ?? data['exercise_id'] ?? 0);
    final titleKo = data['exercise_name'] ?? data['title_ko'] ?? data['name'] ?? '운동';
    
    return Exercise(
      id: id,
      titleKo: titleKo,
      titleEn: data['title_en'],
      descKo: data['desc_ko'] ?? data['description'] ?? '',
      descEn: data['desc_en'],
      difficulty: data['difficulty'] ?? 'beginner',
      difficultyKo: data['difficulty_ko'] ?? '초급',
      type: data['type'] ?? data['custom_type'] ?? 'strength',
      typeKo: data['type_ko'] ?? '근력',
      equipment: data['equipment'] ?? 'none',
      equipmentKo: data['equipment_ko'] ?? '없음',
      primaryMusclesKo: _parseStringList(data['primary_muscles_ko']),
      secondaryMusclesKo: _parseStringList(data['secondary_muscles_ko']),
      musclesUsedKo: _parseStringList(data['muscles_used_ko']),
      caloriesPerMinute: _parseDoubleSafely(data['calories_per_minute']),
      metValue: _parseDoubleSafely(data['met_value']),
      instructions: data['instructions'],
      tips: _parseStringList(data['tips']),
      commonMistakes: data['common_mistakes'],
      category: data['category'],
      tags: _parseStringList(data['tags']),
      recommendedSets: data['recommended_sets'] ?? data['sets']?.toString(),
      recommendedReps: data['recommended_reps'] ?? data['reps']?.toString(),
      recommendedRestSeconds: _parseIntSafely(data['recommended_rest_seconds'] ?? data['rest_seconds']),
      isActive: _parseBoolSafely(data['is_active'], defaultValue: true),
      isPartnerExercise: _parseBoolSafely(data['is_partner_exercise'], defaultValue: false),
      popularityScore: _parseIntSafely(data['popularity_score'] ?? 0),
    );
  }

  /// 안전한 정수 파싱
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  /// 안전한 실수 파싱
  static double? _parseDoubleSafely(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// 안전한 불린 파싱
  static bool _parseBoolSafely(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  /// 안전한 문자열 리스트 파싱
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    
    if (value is String) {
      if (value.trim().isEmpty) return [];
      
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        // JSON 파싱 실패 시 쉼표로 분리 시도
        return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    
    return [];
  }

  /// 데이터 형식 감지
  static ExerciseDataFormat detectDataFormat(dynamic exercisesData) {
    if (exercisesData == null) {
      return ExerciseDataFormat.empty;
    }
    
    if (exercisesData is String) {
      if (exercisesData.trim().isEmpty) {
        return ExerciseDataFormat.empty;
      }
      return ExerciseDataFormat.jsonString;
    }
    
    if (exercisesData is List) {
      if (exercisesData.isEmpty) {
        return ExerciseDataFormat.empty;
      }
      
      // 첫 번째 항목을 확인하여 구조 판단
      final firstItem = exercisesData.first;
      if (firstItem is Map<String, dynamic>) {
        if (firstItem.containsKey('days') || firstItem.containsKey('exercises')) {
          return ExerciseDataFormat.weeklyStructure;
        }
        return ExerciseDataFormat.exerciseList;
      }
      
      return ExerciseDataFormat.exerciseList;
    }
    
    if (exercisesData is Map<String, dynamic>) {
      // 주차 키가 있는지 확인
      final hasWeekKeys = exercisesData.keys.any((key) => key.toString().startsWith('week_'));
      if (hasWeekKeys) {
        return ExerciseDataFormat.weeklyMap;
      }
      
      // exercises 키가 있는지 확인
      if (exercisesData.containsKey('exercises')) {
        return ExerciseDataFormat.exerciseMap;
      }
      
      return ExerciseDataFormat.unknown;
    }
    
    return ExerciseDataFormat.unknown;
  }
}

/// 운동 데이터 형식 열거형
enum ExerciseDataFormat {
  empty,              // null 또는 빈 데이터
  jsonString,         // JSON 문자열
  exerciseList,       // 직접 운동 리스트
  exerciseMap,        // exercises 키를 가진 맵
  weeklyStructure,    // 주차별 구조 (List with week objects)
  weeklyMap,          // 주차별 맵 구조 (Map with week_N keys)
  unknown,            // 알 수 없는 형식
}

/// 형식별 설명
extension ExerciseDataFormatExtension on ExerciseDataFormat {
  String get description {
    switch (this) {
      case ExerciseDataFormat.empty:
        return '빈 데이터';
      case ExerciseDataFormat.jsonString:
        return 'JSON 문자열';
      case ExerciseDataFormat.exerciseList:
        return '운동 리스트';
      case ExerciseDataFormat.exerciseMap:
        return '운동 맵';
      case ExerciseDataFormat.weeklyStructure:
        return '주차별 구조';
      case ExerciseDataFormat.weeklyMap:
        return '주차별 맵';
      case ExerciseDataFormat.unknown:
        return '알 수 없는 형식';
    }
  }
}