import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ExerciseDatabaseService {
  static final ExerciseDatabaseService _instance = ExerciseDatabaseService._internal();
  factory ExerciseDatabaseService() => _instance;
  ExerciseDatabaseService._internal();

  Database? _database;
  static const String _databaseName = 'jfit_exercises.db';
  static const String _assetPath = 'assets/data/jfit_exercises.db';

  /// 데이터베이스 인스턴스 반환
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    print('[DB] 데이터베이스 초기화 시작');
    
    // 앱 문서 디렉토리 경로 가져오기
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    
    print('[DB] 데이터베이스 경로: $path');
    
    // 데이터베이스 파일이 없으면 assets에서 복사
    if (!await File(path).exists()) {
      print('[DB] 데이터베이스 파일이 없음. assets에서 복사 중...');
      await _copyDatabaseFromAssets(path);
    } else {
      print('[DB] 기존 데이터베이스 파일 발견');
    }
    
    // 데이터베이스 열기
    final db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        print('[DB] 데이터베이스 열기 완료');
        await _validateDatabase(db);
      },
    );
    
    return db;
  }

  /// Assets에서 데이터베이스 파일 복사
  Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      print('[DB] Assets에서 데이터베이스 복사 시작: $_assetPath');
      
      // Assets에서 데이터 읽기
      final ByteData data = await rootBundle.load(_assetPath);
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes, 
        data.lengthInBytes
      );
      
      // 파일로 쓰기
      await File(path).writeAsBytes(bytes, flush: true);
      
      print('[DB] 데이터베이스 복사 완료. 크기: ${bytes.length} bytes');
    } catch (e) {
      print('[DB] 데이터베이스 복사 실패: $e');
      
      // assets에서 복사 실패 시 빈 데이터베이스 생성
      print('[DB] 빈 데이터베이스 생성 중...');
      await _createEmptyDatabase(path);
    }
  }

  /// 빈 데이터베이스 생성 (fallback)
  Future<void> _createEmptyDatabase(String path) async {
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        print('[DB] 빈 데이터베이스 테이블 생성 중...');
        
        // exercises 테이블 생성
        await db.execute('''
          CREATE TABLE exercises (
            id INTEGER PRIMARY KEY,
            title_ko TEXT NOT NULL,
            title_en TEXT,
            desc_ko TEXT NOT NULL,
            desc_en TEXT,
            difficulty TEXT NOT NULL,
            difficulty_ko TEXT NOT NULL,
            type TEXT NOT NULL,
            type_ko TEXT NOT NULL,
            equipment TEXT NOT NULL,
            equipment_ko TEXT NOT NULL,
            primary_muscles TEXT,
            primary_muscles_ko TEXT,
            secondary_muscles TEXT,
            secondary_muscles_ko TEXT,
            muscles_used TEXT,
            muscles_used_ko TEXT,
            calories_per_minute REAL,
            met_value REAL,
            instructions TEXT,
            tips TEXT,
            common_mistakes TEXT,
            category TEXT,
            tags TEXT,
            recommended_sets TEXT,
            recommended_reps TEXT,
            recommended_rest_seconds INTEGER,
            is_active INTEGER NOT NULL DEFAULT 1,
            is_partner_exercise INTEGER DEFAULT 0,
            popularity_score INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT,
            sync_status INTEGER DEFAULT 0
          )
        ''');

        // 기본 운동 데이터 삽입
        await _insertSampleData(db);
        
        print('[DB] 빈 데이터베이스 생성 완료');
      },
    );
    await db.close();
  }

  /// 샘플 데이터 삽입
  Future<void> _insertSampleData(Database db) async {
    final sampleExercises = [
      {
        'title_ko': '푸시업',
        'desc_ko': '가슴, 어깨, 삼두근을 강화하는 기본적인 맨몸 운동',
        'difficulty': 'beginner',
        'difficulty_ko': '초급',
        'type': 'strength',
        'type_ko': '근력 운동',
        'equipment': 'bodyweight',
        'equipment_ko': '맨몸',
        'primary_muscles_ko': '["가슴"]',
        'secondary_muscles_ko': '["어깨", "삼두근"]',
        'muscles_used_ko': '["가슴", "어깨", "삼두근"]',
        'calories_per_minute': 8.0,
        'recommended_sets': '3',
        'recommended_reps': '10-15',
        'popularity_score': 95,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title_ko': '스쿼트',
        'desc_ko': '하체 전체를 강화하는 기본적인 맨몸 운동',
        'difficulty': 'beginner',
        'difficulty_ko': '초급',
        'type': 'strength',
        'type_ko': '근력 운동',
        'equipment': 'bodyweight',
        'equipment_ko': '맨몸',
        'primary_muscles_ko': '["대퇴사두근"]',
        'secondary_muscles_ko': '["둔근", "햄스트링"]',
        'muscles_used_ko': '["대퇴사두근", "둔근", "햄스트링"]',
        'calories_per_minute': 10.0,
        'recommended_sets': '3',
        'recommended_reps': '15-20',
        'popularity_score': 90,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title_ko': '플랭크',
        'desc_ko': '코어 근육을 강화하는 정적 운동',
        'difficulty': 'beginner',
        'difficulty_ko': '초급',
        'type': 'strength',
        'type_ko': '근력 운동',
        'equipment': 'bodyweight',
        'equipment_ko': '맨몸',
        'primary_muscles_ko': '["코어"]',
        'secondary_muscles_ko': '["어깨", "등"]',
        'muscles_used_ko': '["코어", "어깨", "등"]',
        'calories_per_minute': 5.0,
        'recommended_sets': '3',
        'recommended_reps': '30-60초',
        'popularity_score': 85,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final exercise in sampleExercises) {
      await db.insert('exercises', exercise);
    }
    
    print('[DB] ${sampleExercises.length}개 샘플 운동 데이터 삽입 완료');
  }

  /// 데이터베이스 유효성 검사
  Future<void> _validateDatabase(Database db) async {
    try {
      // exercises 테이블 존재 확인
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='exercises'"
      );
      
      if (tables.isEmpty) {
        print('[DB] ⚠️ exercises 테이블이 없습니다');
        return;
      }
      
      // 필수 컬럼 존재 여부 확인 (v2 스키마: category_ko 등)
      final columnInfo = await db.rawQuery("PRAGMA table_info(exercises)");
      final columns = columnInfo.map((e) => e['name'] as String).toSet();
      const requiredColumns = {
        'category_ko', 'category_en', 'primary_muscles', 'primary_muscles_ko',
        'secondary_muscles', 'secondary_muscles_ko', 'muscles_used', 'muscles_used_ko'
      };
      final missing = requiredColumns.difference(columns);
      if (missing.isNotEmpty) {
        print('[DB] ❌ 스키마 불일치: 누락 컬럼 -> $missing');
        await db.close();
        // 기존 파일 삭제 후 assets DB 재복사
        final path = db.path;
        print('[DB] 기존 DB 삭제: $path');
        await File(path).delete();
        print('[DB] assets DB로 교체 중...');
        await _copyDatabaseFromAssets(path);
        print('[DB] 교체 완료.');
        return;
      }
      
      // 데이터 개수 확인
      final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM exercises');
      final count = countResult.first['count'] as int;
      
      print('[DB] ✅ 데이터베이스 유효성 검사 완료. 운동 데이터 개수: $count');
      
      if (count == 0) {
        print('[DB] ⚠️ 운동 데이터가 없습니다. 샘플 데이터 삽입 중...');
        await _insertSampleData(db);
      }
      
    } catch (e) {
      print('[DB] ❌ 데이터베이스 유효성 검사 실패: $e');
    }
  }

  /// 데이터베이스 상태 정보 출력
  Future<void> printDatabaseInfo() async {
    try {
      final db = await database;
      
      // 총 운동 개수
      final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM exercises WHERE is_active = 1');
      final totalCount = countResult.first['count'] as int;
      print('[DB] 📊 총 활성 운동 개수: $totalCount');
      
      // 장비별 개수
      final equipmentResult = await db.rawQuery('''
        SELECT equipment_ko, COUNT(*) as count 
        FROM exercises 
        WHERE is_active = 1 
        GROUP BY equipment_ko 
        ORDER BY count DESC 
        LIMIT 5
      ''');
      
      print('[DB] 📋 장비별 운동 개수 (상위 5개):');
      for (final row in equipmentResult) {
        print('   - ${row['equipment_ko']}: ${row['count']}개');
      }
      
      // 인기 운동 TOP 3
      final popularResult = await db.rawQuery('''
        SELECT title_ko, popularity_score 
        FROM exercises 
        WHERE is_active = 1 
        ORDER BY popularity_score DESC 
        LIMIT 3
      ''');
      
      print('[DB] 🏆 인기 운동 TOP 3:');
      for (final row in popularResult) {
        print('   - ${row['title_ko']} (점수: ${row['popularity_score']})');
      }
      
    } catch (e) {
      print('[DB] ❌ 데이터베이스 정보 조회 실패: $e');
    }
  }

  /// 데이터베이스 연결 해제
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('[DB] 데이터베이스 연결 해제');
    }
  }
} 