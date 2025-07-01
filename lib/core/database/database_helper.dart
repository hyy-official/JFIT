import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'jfit.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Exercises 테이블 (운동 기록)
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        exercise_name TEXT NOT NULL,
        exercise_type TEXT NOT NULL,
        duration_minutes INTEGER,
        calories_burned INTEGER,
        intensity TEXT,
        exercise_date TEXT NOT NULL,
        weight REAL,
        sets INTEGER,
        reps INTEGER,
        notes TEXT,
        created_date TEXT,
        updated_date TEXT,
        last_sync_date TEXT,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Food Items 테이블
    await db.execute('''
      CREATE TABLE food_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        serving_size_g REAL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbohydrates REAL NOT NULL,
        fat REAL NOT NULL,
        created_date TEXT,
        updated_date TEXT,
        last_sync_date TEXT,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        is_sample INTEGER DEFAULT 0
      )
    ''');

    // Meal Entries 테이블
    await db.execute('''
      CREATE TABLE meal_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        food_item_id TEXT,
        food_name TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        quantity_g REAL NOT NULL,
        entry_date TEXT NOT NULL,
        calories REAL,
        protein REAL,
        carbohydrates REAL,
        fat REAL,
        created_date TEXT,
        updated_date TEXT,
        last_sync_date TEXT,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (food_item_id) REFERENCES food_items(id)
      )
    ''');

    // Workout Programs 테이블 (JSON 컬럼 사용)
    await db.execute('''
      CREATE TABLE workout_programs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        creator TEXT NOT NULL,
        description TEXT,
        duration_weeks INTEGER NOT NULL,
        difficulty_level TEXT NOT NULL,
        program_type TEXT NOT NULL,
        workouts_per_week INTEGER,
        equipment_needed TEXT, -- JSON 배열
        weekly_schedule TEXT,  -- JSON 객체
        tags TEXT,            -- JSON 배열
        rating REAL,
        is_popular INTEGER DEFAULT 0,
        created_date TEXT,
        updated_date TEXT,
        last_sync_date TEXT,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        is_sample INTEGER DEFAULT 0
      )
    ''');

    // Workout Sessions 테이블
    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        session_name TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        total_duration_minutes INTEGER,
        exercises TEXT,       -- JSON 배열
        is_completed INTEGER DEFAULT 0,
        notes TEXT,
        program_id TEXT,      -- 워크아웃 프로그램 ID
        program_week INTEGER, -- 프로그램의 주차 (예: 1, 2, 3 ...)
        program_day INTEGER,  -- 프로그램의 특정 요일/세션 인덱스
        user_program_id TEXT, -- user_programs FK
        created_date TEXT,
        updated_date TEXT,
        last_sync_date TEXT,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (program_id) REFERENCES workout_programs(id),
        FOREIGN KEY (user_program_id) REFERENCES user_programs(id)
      )
    ''');

    // 인덱스 생성 (성능 최적화)
    await db.execute('CREATE INDEX idx_exercises_user_date ON exercises(user_id, exercise_date)');
    await db.execute('CREATE INDEX idx_meal_entries_user_date ON meal_entries(user_id, entry_date)');
    await db.execute('CREATE INDEX idx_workout_sessions_user ON workout_sessions(user_id)');
    await db.execute('CREATE INDEX idx_sync_status ON exercises(is_synced, updated_date)');

    // Workout Logs 테이블 (사용자 수행 세트 기록)
    await db.execute('''
      CREATE TABLE workout_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT,
        exercise_id TEXT NOT NULL,
        sets INTEGER,
        reps INTEGER,
        weight REAL,
        duration_seconds INTEGER,
        notes TEXT,
        workout_date TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        sync_status INTEGER DEFAULT 1
      )
    ''');

    // User Programs (사용자가 시작한 프로그램 인스턴스)
    await db.execute('''
      CREATE TABLE user_programs (
        id TEXT PRIMARY KEY,
        program_id TEXT NOT NULL,
        current_week INTEGER NOT NULL,
        current_day INTEGER NOT NULL,
        started_at TEXT,
        completed_at TEXT,
        custom_json TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 워크아웃 세션 테이블에 program_id, program_day 컬럼 추가
      await db.execute('ALTER TABLE workout_sessions ADD COLUMN program_id TEXT');
      await db.execute('ALTER TABLE workout_sessions ADD COLUMN program_day TEXT');
    }

    if (oldVersion < 3) {
      // 기존 DB 에 workout_logs 가 없을 경우 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workout_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id TEXT,
          exercise_id TEXT NOT NULL,
          sets INTEGER,
          reps INTEGER,
          weight REAL,
          duration_seconds INTEGER,
          notes TEXT,
          workout_date TEXT NOT NULL,
          created_at TEXT DEFAULT (datetime('now')),
          sync_status INTEGER DEFAULT 1
        )
      ''');
    }

    if (oldVersion < 4) {
      // users 테이블 더 이상 사용하지 않음
      await db.execute('DROP TABLE IF EXISTS users');
    }

    if (oldVersion < 5) {
      // user_programs 테이블 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_programs (
          id TEXT PRIMARY KEY,
          program_id TEXT NOT NULL,
          current_week INTEGER NOT NULL,
          current_day INTEGER NOT NULL,
          started_at TEXT,
          completed_at TEXT,
          custom_json TEXT,
          is_active INTEGER DEFAULT 1
        )
      ''');

      // workout_sessions 테이블에 신규 컬럼을 추가합니다. 이미 존재한다면 건너뜁니다.
      final sessionColumns = await db.rawQuery('PRAGMA table_info(workout_sessions)');
      final columnNames = sessionColumns.map((row) => (row['name'] ?? '').toString()).toList();

      if (!columnNames.contains('user_program_id')) {
        await db.execute('ALTER TABLE workout_sessions ADD COLUMN user_program_id TEXT');
      }
      if (!columnNames.contains('program_week')) {
        await db.execute('ALTER TABLE workout_sessions ADD COLUMN program_week INTEGER');
      }
      if (!columnNames.contains('program_day')) {
        await db.execute('ALTER TABLE workout_sessions ADD COLUMN program_day INTEGER');
      }
    }
  }

  // CRUD Operations for Exercises
  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    exercise['created_date'] = DateTime.now().toIso8601String();
    exercise['updated_date'] = DateTime.now().toIso8601String();
    exercise['is_synced'] = 0; // 동기화 필요 표시
    
    return await db.insert('exercises', exercise);
  }

  /// Returns the most recent exercise log for the given exercise name.
  /// If no record exists, `null` is returned.
  Future<Map<String, dynamic>?> getLastExerciseLog(String exerciseName) async {
    final db = await database;
    final results = await db.query(
      'exercises',
      where: 'exercise_name = ? AND is_deleted = 0',
      whereArgs: [exerciseName],
      orderBy: 'exercise_date DESC, created_date DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Map<String, dynamic>.from(results.first);
  }

  Future<List<Map<String, dynamic>>> getExercises({String? userId, String? date}) async {
    final db = await database;
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }

    if (date != null) {
      whereClause += ' AND exercise_date = ?';
      whereArgs.add(date);
    }

    return await db.query(
      'exercises',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'exercise_date DESC, created_date DESC',
    );
  }

  Future<int> updateExercise(String id, Map<String, dynamic> exercise) async {
    final db = await database;
    exercise['updated_date'] = DateTime.now().toIso8601String();
    exercise['is_synced'] = 0; // 동기화 필요 표시
    
    return await db.update(
      'exercises',
      exercise,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExercise(String id) async {
    final db = await database;
    // Soft delete - 서버 동기화를 위해
    return await db.update(
      'exercises',
      {
        'is_deleted': 1,
        'updated_date': DateTime.now().toIso8601String(),
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Food Items
  Future<int> insertFoodItem(Map<String, dynamic> foodItem) async {
    final db = await database;
    foodItem['created_date'] = DateTime.now().toIso8601String();
    foodItem['updated_date'] = DateTime.now().toIso8601String();
    foodItem['is_synced'] = 0;
    
    return await db.insert('food_items', foodItem);
  }

  Future<List<Map<String, dynamic>>> getFoodItems({String? searchQuery}) async {
    final db = await database;
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ' AND name LIKE ?';
      whereArgs.add('%$searchQuery%');
    }

    return await db.query(
      'food_items',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );
  }

  // CRUD Operations for Meal Entries
  Future<int> insertMealEntry(Map<String, dynamic> mealEntry) async {
    final db = await database;
    mealEntry['created_date'] = DateTime.now().toIso8601String();
    mealEntry['updated_date'] = DateTime.now().toIso8601String();
    mealEntry['is_synced'] = 0;
    
    return await db.insert('meal_entries', mealEntry);
  }

  Future<List<Map<String, dynamic>>> getMealEntries({String? userId, String? date}) async {
    final db = await database;
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }

    if (date != null) {
      whereClause += ' AND entry_date = ?';
      whereArgs.add(date);
    }

    return await db.query(
      'meal_entries',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'entry_date DESC, created_date DESC',
    );
  }

  // CRUD Operations for Workout Programs
  Future<int> insertWorkoutProgram(Map<String, dynamic> program) async {
    final db = await database;
    
    // JSON 필드들을 문자열로 변환
    if (program['equipment_needed'] is List) {
      program['equipment_needed'] = jsonEncode(program['equipment_needed']);
    }
    if (program['weekly_schedule'] is List) {
      program['weekly_schedule'] = jsonEncode(program['weekly_schedule']);
    }
    if (program['tags'] is List) {
      program['tags'] = jsonEncode(program['tags']);
    }
    
    program['created_date'] = DateTime.now().toIso8601String();
    program['updated_date'] = DateTime.now().toIso8601String();
    program['is_synced'] = 0;
    
    return await db.insert('workout_programs', program);
  }

  Future<List<Map<String, dynamic>>> getWorkoutPrograms({
    String? searchQuery,
    String? difficultyLevel,
    String? programType,
  }) async {
    final db = await database;
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ' AND (name LIKE ? OR creator LIKE ? OR description LIKE ?)';
      whereArgs.addAll(['%$searchQuery%', '%$searchQuery%', '%$searchQuery%']);
    }

    if (difficultyLevel != null && difficultyLevel != 'all') {
      whereClause += ' AND difficulty_level = ?';
      whereArgs.add(difficultyLevel);
    }

    if (programType != null && programType != 'all') {
      whereClause += ' AND program_type = ?';
      whereArgs.add(programType);
    }

    final results = await db.query(
      'workout_programs',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'is_popular DESC, rating DESC, name ASC',
    );

    // JSON 필드들을 다시 파싱
    return results.map((program) {
      final parsedProgram = Map<String, dynamic>.from(program);
      
      if (parsedProgram['equipment_needed'] is String) {
        try {
          parsedProgram['equipment_needed'] = jsonDecode(parsedProgram['equipment_needed']);
        } catch (e) {
          parsedProgram['equipment_needed'] = [];
        }
      }
      
      if (parsedProgram['weekly_schedule'] is String) {
        try {
          parsedProgram['weekly_schedule'] = jsonDecode(parsedProgram['weekly_schedule']);
        } catch (e) {
          parsedProgram['weekly_schedule'] = [];
        }
      }
      
      if (parsedProgram['tags'] is String) {
        try {
          parsedProgram['tags'] = jsonDecode(parsedProgram['tags']);
        } catch (e) {
          parsedProgram['tags'] = [];
        }
      }
      
      return parsedProgram;
    }).toList();
  }

  Future<Map<String, dynamic>?> getWorkoutProgramById(String id) async {
    final db = await database;
    final results = await db.query(
      'workout_programs',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final program = Map<String, dynamic>.from(results.first);
    
    // JSON 필드들을 다시 파싱
    if (program['equipment_needed'] is String) {
      try {
        program['equipment_needed'] = jsonDecode(program['equipment_needed']);
      } catch (e) {
        program['equipment_needed'] = [];
      }
    }
    
    if (program['weekly_schedule'] is String) {
      try {
        program['weekly_schedule'] = jsonDecode(program['weekly_schedule']);
      } catch (e) {
        program['weekly_schedule'] = [];
      }
    }
    
    if (program['tags'] is String) {
      try {
        program['tags'] = jsonDecode(program['tags']);
      } catch (e) {
        program['tags'] = [];
      }
    }
    
    return program;
  }

  // CRUD Operations for Workout Sessions
  Future<int> insertWorkoutSession(Map<String, dynamic> session) async {
    final db = await database;
    
    if (session['exercises'] is List) {
      session['exercises'] = jsonEncode(session['exercises']);
    }
    
    // ID가 있으면 업데이트, 없으면 생성
    if (session['id'] != null) {
      session['updated_date'] = DateTime.now().toIso8601String();
      session['is_synced'] = 0;
      
      await db.update(
        'workout_sessions',
        session,
        where: 'id = ?',
        whereArgs: [session['id']],
      );
      return session['id'];
    } else {
      session['created_date'] = DateTime.now().toIso8601String();
      session['updated_date'] = DateTime.now().toIso8601String();
      session['is_synced'] = 0;
      
      return await db.insert('workout_sessions', session);
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutSessions({String? userId}) async {
    final db = await database;
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }

    final results = await db.query(
      'workout_sessions',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'start_time DESC',
    );

    // JSON 필드 파싱
    return results.map((session) {
      final parsedSession = Map<String, dynamic>.from(session);
      
      if (parsedSession['exercises'] is String) {
        try {
          parsedSession['exercises'] = jsonDecode(parsedSession['exercises']);
        } catch (e) {
          parsedSession['exercises'] = [];
        }
      }
      
      return parsedSession;
    }).toList();
  }

  // 동기화 관련 메서드들
  Future<List<Map<String, dynamic>>> getUnsyncedData(String tableName) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'is_synced = 0',
      orderBy: 'updated_date ASC',
    );
  }

  Future<void> markAsSynced(String tableName, String id) async {
    final db = await database;
    await db.update(
      tableName,
      {
        'is_synced': 1,
        'last_sync_date': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 데이터베이스 초기화 (개발/테스트용)
  Future<void> clearDatabase() async {
    final db = await database;
    final tables = ['exercises', 'food_items', 'meal_entries', 'workout_programs', 'workout_sessions'];
    
    for (final table in tables) {
      await db.delete(table);
    }
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Insert a workout log; exerciseId is required (FK to exercises).
  Future<int> insertWorkoutLog({
    required String exerciseId,
    required int sets,
    required int reps,
    required double weight,
    String? sessionId,
  }) async {
    final db = await database;
    return await db.insert('workout_logs', {
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'workout_date': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getLastWorkoutLogByExerciseId(String exerciseId) async {
    final db = await database;
    final results = await db.query(
      'workout_logs',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'workout_date DESC, id DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Map<String, dynamic>.from(results.first);
  }

  Future<String?> getExerciseIdByName(String name) async {
    final db = await database;
    final rows = await db.query(
      'exercises',
      columns: ['id'],
      where: 'exercise_name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as String;
  }

  // User Programs CRUD
  Future<int> insertUserProgram(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('user_programs', data);
  }

  Future<Map<String, dynamic>?> getActiveUserProgram(String programId) async {
    final db = await database;
    final rows = await db.query(
      'user_programs',
      where: 'program_id = ? AND is_active = 1',
      whereArgs: [programId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  Future<void> updateUserProgram(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('user_programs', data, where: 'id = ?', whereArgs: [id]);
  }

  /// Return the most recently started active user program, or null if none.
  Future<Map<String, dynamic>?> getLatestActiveUserProgram() async {
    final db = await database;
    final rows = await db.query(
      'user_programs',
      where: 'is_active = 1',
      orderBy: 'started_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }
} 