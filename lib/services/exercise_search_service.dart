import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import 'exercise_database_service.dart';
import 'dart:convert';

/// 필터 옵션을 위한 데이터 클래스
class FilterOption {
  final String ko;
  final String en;
  int count;

  FilterOption({required this.ko, required this.en, this.count = 0});
}

class ExerciseSearchService {
  final ExerciseDatabaseService _dbService = ExerciseDatabaseService();

  // 사전 정의된 장비 목록 (순서 보장)
  static const List<String> _equipmentKo = [
    '밴드', '바벨', '케틀벨', '덤벨', '기타', '케이블', '머신', '맨몸', '메디슨볼', '짐볼', '폼롤러', 'EZ 바', 'GHD 벤치', '스미스 머신'
  ];
  static const List<String> _equipmentEn = [
    'Bands', 'Barbell', 'Kettlebells', 'Dumbbells', 'Other', 'Cable', 'Machine', 'Body Only', 'Medicine Ball', 'Exercise Ball', 'Foam Roll', 'E-Z Curl Bar', 'GHD Bench', 'Smith machine'
  ];

  // 사전 정의된 난이도, 운동 타입, 근육 부위 리스트 (순서 보장)
  static const List<String> _difficultyKo = ['초급', '중급', '상급'];
  static const List<String> _difficultyEn = ['Beginner', 'Intermediate', 'Advanced'];

  static const List<String> _exerciseTypeKo = ['근력 운동', '유산소', '유연성'];
  static const List<String> _exerciseTypeEn = ['Strength', 'Cardio', 'Flexibility'];

  static const List<String> _muscleGroupKo = ['가슴', '어깨', '팔', '등', '다리', '엉덩이', '코어'];
  static const List<String> _muscleGroupEn = ['Chest', 'Shoulders', 'Arms', 'Back', 'Legs', 'Glutes', 'Core'];

  /// 텍스트 검색 (다국어 지원)
  Future<List<Exercise>> searchExercises({
    required String query,
    List<String>? equipmentFilters,
    List<String>? difficultyFilters,
    List<String>? typeFilters,
    List<String>? muscleFilters,
    String sortBy = 'popularity_score',
    bool sortDesc = true,
    int limit = 50,
    Locale? locale,
  }) async {
    print('[SEARCH] 검색 시작 - 쿼리: "$query"');
    
    final db = await _dbService.database;
    
    String sql = 'SELECT * FROM exercises WHERE is_active = 1';
    List<dynamic> params = [];

    // 텍스트 검색 (다국어 지원)
    if (query.isNotEmpty) {
      final isKorean = locale?.languageCode == 'ko';
      final searchParam = '%$query%';
      
      if (isKorean) {
        // 한국어: 한국어 필드 우선 검색, 영어 필드도 포함
        sql += ' AND (title_ko LIKE ? OR desc_ko LIKE ? OR title_en LIKE ? OR desc_en LIKE ?)';
        params.add(searchParam); // title_ko
        params.add(searchParam); // desc_ko
        params.add(searchParam); // title_en
        params.add(searchParam); // desc_en
      } else {
        // 영어: 영어 필드 우선 검색, 한국어 필드도 포함
        sql += ' AND (title_en LIKE ? OR desc_en LIKE ? OR title_ko LIKE ? OR desc_ko LIKE ?)';
        params.add(searchParam); // title_en
        params.add(searchParam); // desc_en
        params.add(searchParam); // title_ko
        params.add(searchParam); // desc_ko
      }
    }

    // 장비 필터 (한/영 모두 지원)
    if (equipmentFilters != null && equipmentFilters.isNotEmpty) {
      final placeholders = equipmentFilters.map((e) => '?').join(',');
      sql += ' AND (equipment_ko IN ($placeholders) OR equipment IN ($placeholders))';
      // 동일 파라미터 세트를 두 번 사용
      params.addAll(equipmentFilters);
      params.addAll(equipmentFilters);
    }

    // 난이도 필터 (한/영 모두 지원)
    if (difficultyFilters != null && difficultyFilters.isNotEmpty) {
      final placeholders = difficultyFilters.map((e) => '?').join(',');
      sql += ' AND (difficulty_ko IN ($placeholders) OR difficulty IN ($placeholders))';
      params.addAll(difficultyFilters);
      params.addAll(difficultyFilters);
    }

    // 운동 타입 필터 - 여러 관련 필드를 동시에 검색하도록 수정 (한/영 모두 지원)
    if (typeFilters != null && typeFilters.isNotEmpty) {
      sql += ' AND (';
      for (int i = 0; i < typeFilters.length; i++) {
        if (i > 0) {
          sql += ' OR ';
        }
        final filterTerm = typeFilters[i];
        // category, primary_muscles, type 컬럼의 한/영 버전 모두 검색
        sql += '((category_ko LIKE ? OR category_en LIKE ?) OR (primary_muscles_ko LIKE ? OR primary_muscles LIKE ?) OR (type_ko LIKE ? OR type LIKE ?))';
        params.addAll(List.filled(6, '%$filterTerm%'));
      }
      sql += ')';
    }

    // 근육(카테고리) 필터 - 여러 선택항목을 OR 조건으로 묶고, 한/영 컬럼 모두 검색하도록 수정
    if (muscleFilters != null && muscleFilters.isNotEmpty) {
      sql += ' AND (';
      for (int i = 0; i < muscleFilters.length; i++) {
        if (i > 0) {
          sql += ' OR ';
        }
        final muscle = muscleFilters[i];
        sql += '((category_ko LIKE ? OR category_en LIKE ? OR primary_muscles_ko LIKE ? OR primary_muscles LIKE ? OR secondary_muscles_ko LIKE ? OR secondary_muscles LIKE ?))';
        final param = '%$muscle%';
        // 한/영 컬럼 각각에 대해 파라미터 설정
        params.addAll([param, param, param, param, param, param]);
      }
      sql += ')';
    }

    // 정렬 (다국어 지원)
    final isKorean = locale?.languageCode == 'ko';
    if (query.isNotEmpty && isKorean) {
      // 한국어 검색 시: 한국어 제목 매치 우선, 그 다음 인기도
      sql += ' ORDER BY CASE WHEN title_ko LIKE ? THEN 0 ELSE 1 END, $sortBy ${sortDesc ? 'DESC' : 'ASC'}';
      params.add('%$query%');
    } else if (query.isNotEmpty && !isKorean) {
      // 영어 검색 시: 영어 제목 매치 우선, 그 다음 인기도
      sql += ' ORDER BY CASE WHEN title_en LIKE ? THEN 0 ELSE 1 END, $sortBy ${sortDesc ? 'DESC' : 'ASC'}';
      params.add('%$query%');
    } else {
      // 일반 정렬
      sql += ' ORDER BY $sortBy ${sortDesc ? 'DESC' : 'ASC'}';
    }
    sql += ' LIMIT $limit';

    print('[SEARCH] SQL: $sql');
    print('[SEARCH] Params count: ${params.length}');
    for (int i = 0; i < params.length; i++) {
      print('[SEARCH] Param[$i]: ${params[i]}');
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, params);
    final exercises = maps.map((map) => Exercise.fromMap(map)).toList();
    
    print('[SEARCH] 검색 완료 - 결과: ${exercises.length}개');
    return exercises;
  }

  /// 인기 운동 조회
  Future<List<Exercise>> getPopularExercises({int limit = 20}) async {
    print('[SEARCH] 인기 운동 조회 시작');
    
    final db = await _dbService.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'is_active = 1',
      orderBy: 'popularity_score DESC',
      limit: limit,
    );
    
    final exercises = maps.map((map) => Exercise.fromMap(map)).toList();
    print('[SEARCH] 인기 운동 조회 완료 - 결과: ${exercises.length}개');
    
    return exercises;
  }

  /// 운동 상세 정보 조회
  Future<Exercise?> getExerciseById(int id) async {
    final db = await _dbService.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'id = ? AND is_active = 1',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  /// 장비별 운동 개수 조회 (사전 정의된 목록 기준)
  Future<Map<String, int>> getEquipmentCounts() async {
    final db = await _dbService.database;

    // 데이터베이스에서 실제 장비별 개수 조회
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT equipment_ko, COUNT(*) as count
      FROM exercises
      WHERE is_active = 1 AND equipment_ko != ''
      GROUP BY equipment_ko
    ''');

    final dbCounts = Map.fromEntries(
        results.map((r) => MapEntry(r['equipment_ko'] as String, r['count'] as int)));

    // 최종 결과를 담을 Map (사전 정의된 목록 순서 보장)
    final Map<String, int> finalCounts = {};
    for (var equipment in _equipmentKo) {
      finalCounts[equipment] = dbCounts[equipment] ?? 0;
    }

    return finalCounts;
  }

  /// UI용 장비 필터 옵션 목록 조회
  Future<List<FilterOption>> getEquipmentOptions() async {
    final counts = await getEquipmentCounts();
    List<FilterOption> options = [];

    for (int i = 0; i < _equipmentKo.length; i++) {
      final ko = _equipmentKo[i];
      final en = _equipmentEn[i];
      options.add(FilterOption(
        ko: ko,
        en: en,
        count: counts[ko] ?? 0,
      ));
    }
    return options;
  }

  /// 난이도별 운동 개수 조회
  Future<Map<String, int>> getDifficultyCounts() async {
    final db = await _dbService.database;
    
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT difficulty_ko, COUNT(*) as count
      FROM exercises
      WHERE is_active = 1
      GROUP BY difficulty_ko
      ORDER BY count DESC
    ''');
    
    return Map.fromEntries(
      results.map((r) => MapEntry(r['difficulty_ko'] as String, r['count'] as int))
    );
  }

  /// 운동 타입별 개수 조회
  Future<Map<String, int>> getTypeCounts() async {
    final db = await _dbService.database;
    // NULL 또는 빈 값 제외 후 그룹핑
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT category_ko, COUNT(*) as count
      FROM exercises
      WHERE is_active = 1 AND category_ko IS NOT NULL AND category_ko != ''
      GROUP BY category_ko
      ORDER BY count DESC
    ''');

    // 안전한 캐스팅 처리
    return Map.fromEntries(
      results.where((r) => r['category_ko'] != null).map((r) => MapEntry(r['category_ko'] as String, r['count'] as int))
    );
  }

  /// 유사 운동 추천
  Future<List<Exercise>> getSimilarExercises(Exercise exercise, {int limit = 10}) async {
    final db = await _dbService.database;
    
    // 같은 주동근과 장비를 사용하는 운동 추천
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM exercises
      WHERE id != ? 
        AND is_active = 1
        AND (equipment_ko = ? OR primary_muscles_ko LIKE ?)
      ORDER BY 
        CASE WHEN equipment_ko = ? THEN 1 ELSE 2 END,
        popularity_score DESC
      LIMIT ?
    ''', [
      exercise.id,
      exercise.equipmentKo,
      '%${exercise.primaryMusclesKo.isNotEmpty ? exercise.primaryMusclesKo.first : ''}%',
      exercise.equipmentKo,
      limit
    ]);
    
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  /// 빠른 검색 (자동완성용, 다국어 지원)
  Future<List<String>> getExerciseNameSuggestions(String query, {int limit = 10, Locale? locale}) async {
    if (query.length < 2) return [];
    
    final db = await _dbService.database;
    final isKorean = locale?.languageCode == 'ko';
    
    String sql;
    String titleField;
    
    if (isKorean) {
      titleField = 'title_ko';
      sql = '''
        SELECT DISTINCT title_ko
        FROM exercises
        WHERE is_active = 1 AND (title_ko LIKE ? OR title_en LIKE ?)
        ORDER BY CASE WHEN title_ko LIKE ? THEN 0 ELSE 1 END, popularity_score DESC
        LIMIT ?
      ''';
    } else {
      titleField = 'title_en';
      sql = '''
        SELECT DISTINCT COALESCE(title_en, title_ko) as title_en
        FROM exercises
        WHERE is_active = 1 AND (title_en LIKE ? OR title_ko LIKE ?)
        ORDER BY CASE WHEN title_en LIKE ? THEN 0 ELSE 1 END, popularity_score DESC
        LIMIT ?
      ''';
    }
    
    final searchParam = '%$query%';
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, [
      searchParam, // first LIKE
      searchParam, // second LIKE  
      searchParam, // ORDER BY CASE
      limit
    ]);
    
    return maps.map((map) => map[titleField] as String).where((title) => title.isNotEmpty).toList();
  }

  /// 난이도별 필터 옵션
  Future<List<FilterOption>> getDifficultyOptions() async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT difficulty_ko, COUNT(*) as count
      FROM exercises
      WHERE is_active = 1 AND difficulty_ko != ''
      GROUP BY difficulty_ko
    ''');

    final counts = Map.fromEntries(
        results.map((r) => MapEntry(r['difficulty_ko'] as String, r['count'] as int)));

    List<FilterOption> options = [];
    for (int i = 0; i < _difficultyKo.length; i++) {
      final ko = _difficultyKo[i];
      final en = _difficultyEn[i];
      options.add(FilterOption(ko: ko, en: en, count: counts[ko] ?? 0));
    }
    return options;
  }

  /// 운동 타입별 필터 옵션
  Future<List<FilterOption>> getExerciseTypeOptions() async {
    final counts = await getTypeCounts();
    List<FilterOption> options = [];
    for (int i = 0; i < _exerciseTypeKo.length; i++) {
      final ko = _exerciseTypeKo[i];
      final en = _exerciseTypeEn[i];
      options.add(FilterOption(ko: ko, en: en, count: counts[ko] ?? 0));
    }
    return options;
  }

  /// 근육 그룹 필터 옵션 (JSON 파싱)
  Future<List<FilterOption>> getMuscleGroupOptions() async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT category_ko
      FROM exercises
      WHERE is_active = 1 AND category_ko != ''
    ''');

    // 카운트 맵 초기화
    final Map<String, int> counts = {for (var m in _muscleGroupKo) m: 0};

    for (var row in rows) {
      final field = row['category_ko'];
      if (field == null || (field is String && field.isEmpty)) continue;
      List<dynamic> list;
      try {
        list = jsonDecode(field as String);
      } catch (_) {
        continue;
      }
      for (var cat in list) {
        if (cat is String && counts.containsKey(cat)) {
          counts[cat] = counts[cat]! + 1;
        }
      }
    }

    List<FilterOption> options = [];
    for (int i = 0; i < _muscleGroupKo.length; i++) {
      final ko = _muscleGroupKo[i];
      final en = _muscleGroupEn[i];
      options.add(FilterOption(ko: ko, en: en, count: counts[ko] ?? 0));
    }
    return options;
  }
} 