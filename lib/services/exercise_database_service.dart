/*
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jfit/models/exercise.dart';

class ExerciseDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'jfit_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE exercises(id TEXT PRIMARY KEY, name TEXT, type TEXT, description TEXT)",
        );
        await db.execute(
          "CREATE TABLE workout_programs(id TEXT PRIMARY KEY, name TEXT, creator TEXT, description TEXT, duration_weeks INTEGER, difficulty_level TEXT, program_type TEXT, workouts_per_week INTEGER, equipment_needed TEXT, weekly_schedule TEXT, tags TEXT, rating REAL, is_popular INTEGER, is_sample INTEGER)",
        );
        await db.execute(
          "CREATE TABLE user_exercises(id TEXT PRIMARY KEY, user_id TEXT, exercise_name TEXT, exercise_type TEXT, duration_minutes INTEGER, calories_burned INTEGER, intensity TEXT, exercise_date TEXT, weight REAL, sets INTEGER, reps INTEGER, notes TEXT, is_synced INTEGER DEFAULT 0)",
        );
        await db.execute(
          "CREATE TABLE food_items(id TEXT PRIMARY KEY, name TEXT, serving_size_g REAL, calories REAL, protein REAL, carbohydrates REAL, fat REAL, is_sample INTEGER)",
        );
        await db.execute(
          "CREATE TABLE meal_entries(id TEXT PRIMARY KEY, user_id TEXT, food_item_id TEXT, food_name TEXT, meal_type TEXT, quantity_g REAL, entry_date TEXT, calories REAL, protein REAL, carbohydrates REAL, fat REAL, is_synced INTEGER DEFAULT 0)",
        );
        await db.execute(
          "CREATE TABLE user_profile(id TEXT PRIMARY KEY, user_id TEXT, height REAL, weight REAL, goal TEXT, activity_level TEXT, is_synced INTEGER DEFAULT 0)",
        );
        await db.execute(
          "CREATE TABLE workout_sessions(id TEXT PRIMARY KEY, user_id TEXT, session_date TEXT, total_duration_minutes INTEGER, total_calories_burned INTEGER, notes TEXT, is_synced INTEGER DEFAULT 0)",
        );
        print('Database created and tables initialized');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 데이터베이스 스키마 변경 시 마이그레이션 로직
        if (oldVersion < 1) {
          // 버전 1로 업그레이드
        }
      },
    );
  }

  Future<void> printDatabaseInfo() async {
    final db = await database;
    final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
    print('Tables in database: $tables');

    for (var table in tables) {
      final tableName = table['name'];
      if (tableName != null) {
        final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
        print('Table $tableName has $count rows');
      }
    }
  }

  // CRUD operations for exercises
  Future<void> insertExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    await db.insert('exercises', exercise, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getExercises() async {
    final db = await database;
    return await db.query('exercises');
  }

  // CRUD operations for workout programs
  Future<void> insertWorkoutProgram(Map<String, dynamic> program) async {
    final db = await database;
    await db.insert('workout_programs', program, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getWorkoutPrograms() async {
    final db = await database;
    return await db.query('workout_programs');
  }

  Future<Map<String, dynamic>?> getWorkoutProgramById(String id) async {
    final db = await database;
    final result = await db.query('workout_programs', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateWorkoutProgram(String id, Map<String, dynamic> program) async {
    final db = await database;
    await db.update('workout_programs', program, where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for user_exercises
  Future<void> insertUserExercise(Map<String, dynamic> userExercise) async {
    final db = await database;
    await db.insert('user_exercises', userExercise, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUserExercises() async {
    final db = await database;
    return await db.query('user_exercises');
  }

  Future<Map<String, dynamic>?> getUserExerciseById(String id) async {
    final db = await database;
    final result = await db.query('user_exercises', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUserExercise(String id, Map<String, dynamic> userExercise) async {
    final db = await database;
    await db.update('user_exercises', userExercise, where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for food_items
  Future<void> insertFoodItem(Map<String, dynamic> foodItem) async {
    final db = await database;
    await db.insert('food_items', foodItem, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFoodItems() async {
    final db = await database;
    return await db.query('food_items');
  }

  Future<Map<String, dynamic>?> getFoodItemById(String id) async {
    final db = await database;
    final result = await db.query('food_items', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateFoodItem(String id, Map<String, dynamic> foodItem) async {
    final db = await database;
    await db.update('food_items', foodItem, where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for meal_entries
  Future<void> insertMealEntry(Map<String, dynamic> mealEntry) async {
    final db = await database;
    await db.insert('meal_entries', mealEntry, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getMealEntries() async {
    final db = await database;
    return await db.query('meal_entries');
  }

  Future<Map<String, dynamic>?> getMealEntryById(String id) async {
    final db = await database;
    final result = await db.query('meal_entries', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateMealEntry(String id, Map<String, dynamic> mealEntry) async {
    final db = await database;
    await db.update('meal_entries', mealEntry, where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for user_profile
  Future<void> insertUserProfile(Map<String, dynamic> userProfile) async {
    final db = await database;
    await db.insert('user_profile', userProfile, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final db = await database;
    final result = await db.query('user_profile', where: 'user_id = ?', whereArgs: [userId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> userProfile) async {
    final db = await database;
    await db.update('user_profile', userProfile, where: 'user_id = ?', whereArgs: [userId]);
  }

  // CRUD operations for workout_sessions
  Future<void> insertWorkoutSession(Map<String, dynamic> session) async {
    final db = await database;
    await db.insert('workout_sessions', session, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getWorkoutSessions() async {
    final db = await database;
    return await db.query('workout_sessions');
  }

  Future<Map<String, dynamic>?> getWorkoutSessionById(String id) async {
    final db = await database;
    final result = await db.query('workout_sessions', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateWorkoutSession(String id, Map<String, dynamic> session) async {
    final db = await database;
    await db.update('workout_sessions', session, where: 'id = ?', whereArgs: [id]);
  }

  // 동기화 관련
  Future<List<Map<String, dynamic>>> getUnsyncedRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> unsynced = [];

    // 각 테이블에서 is_synced가 0인 레코드 조회
    final tables = ['user_exercises', 'meal_entries', 'workout_sessions', 'user_profile'];
    for (final table in tables) {
      final records = await db.query(table, where: 'is_synced = ?', whereArgs: [0]);
      for (var record in records) {
        unsynced.add({
          'table_name': table,
          'operation': 'upsert', // 또는 'delete' 등
          ...record,
        });
      }
    }
    return unsynced;
  }

  Future<void> markRecordAsSynced(String id, String tableName) async {
    final db = await database;
    await db.update(
      tableName,
      {'is_synced': 1, 'last_sync_date': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markRecordForResync(String id, String tableName) async {
    final db = await database;
    await db.update(
      tableName,
      {'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 데이터베이스 초기화
  Future<void> clearDatabase() async {
    String path = join(await getDatabasesPath(), 'jfit_database.db');
    await deleteDatabase(path);
    _database = null; // 데이터베이스 객체 초기화
    print('Database cleared');
  }
} 
*/