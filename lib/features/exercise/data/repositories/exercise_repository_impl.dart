import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/core/models/exercise.dart';
import 'package:jfit/features/exercise/data/repositories/exercise_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of ExerciseRepository using Supabase as the data source
class ExerciseRepositoryImpl extends ExerciseRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;
  
  // Simple in-memory cache for frequently accessed data
  final Map<String, Exercise> _exerciseCache = {};
  final Map<String, List<Exercise>> _searchCache = {};
  final Map<String, List<String>> _stringListCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache duration - 30 minutes
  static const Duration _cacheDuration = Duration(minutes: 30);

  ExerciseRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<Exercise>>> search(
    String query, {
    int? limit,
  }) async {
    return safeCall(() async {
      // Check cache first
      final cacheKey = 'search_${query}_${limit ?? 'all'}';
      if (_isCacheValid(cacheKey)) {
        return _searchCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('*')
          .or('title_ko.ilike.%$query%,title_en.ilike.%$query%')
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .limit(limit ?? 20);

      final exercises = (response as List)
          .map((json) => Exercise.fromMap(json))
          .toList();

      // Cache the results
      _searchCache[cacheKey] = exercises;
      _cacheTimestamps[cacheKey] = DateTime.now();

      // Also cache individual exercises
      for (final exercise in exercises) {
        _exerciseCache[exercise.id.toString()] = exercise;
        _cacheTimestamps[exercise.id.toString()] = DateTime.now();
      }

      return exercises;
    });
  }

  @override
  Future<Either<Failure, List<Exercise>>> searchWithFilters(
    String query,
    Map<String, dynamic> filters, {
    int? limit,
  }) async {
    return safeCall(() async {
      // Build cache key from query and filters
      final filterString = filters.entries
          .map((e) => '${e.key}:${e.value}')
          .join('_');
      final cacheKey = 'search_filtered_${query}_${filterString}_${limit ?? 'all'}';
      
      if (_isCacheValid(cacheKey)) {
        return _searchCache[cacheKey]!;
      }

      var queryBuilder = _supabaseClient
          .from('exercises')
          .select('*')
          .eq('is_active', true);

      // Apply search query
      if (query.isNotEmpty) {
        queryBuilder = queryBuilder
            .or('title_ko.ilike.%$query%,title_en.ilike.%$query%');
      }

      // Apply filters
      filters.forEach((key, value) {
        switch (key) {
          case 'difficulty':
            queryBuilder = queryBuilder.eq('difficulty', value);
            break;
          case 'type':
            queryBuilder = queryBuilder.eq('type', value);
            break;
          case 'equipment':
            queryBuilder = queryBuilder.eq('equipment', value);
            break;
          case 'category':
            queryBuilder = queryBuilder.eq('category', value);
            break;
          case 'muscle_group':
            // Search in primary_muscles_ko, secondary_muscles_ko, or muscles_used_ko
            queryBuilder = queryBuilder.or(
              'primary_muscles_ko.cs.["$value"],'
              'secondary_muscles_ko.cs.["$value"],'
              'muscles_used_ko.cs.["$value"]'
            );
            break;
        }
      });

      final response = await queryBuilder
          .order('popularity_score', ascending: false)
          .limit(limit ?? 20);

      final exercises = (response as List)
          .map((json) => Exercise.fromMap(json))
          .toList();

      // Cache the results
      _searchCache[cacheKey] = exercises;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return exercises;
    });
  }

  @override
  Future<Either<Failure, Exercise?>> getExerciseById(String exerciseId) async {
    return safeCall(() async {
      // Check cache first
      if (_isCacheValid(exerciseId)) {
        return _exerciseCache[exerciseId];
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('*')
          .eq('id', exerciseId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final exercise = Exercise.fromMap(response);
      
      // Cache the result
      _exerciseCache[exerciseId] = exercise;
      _cacheTimestamps[exerciseId] = DateTime.now();

      return exercise;
    });
  }

  @override
  Future<Either<Failure, List<Exercise>>> getExercisesByIds(
    List<String> exerciseIds,
  ) async {
    return safeCall(() async {
      final exercises = <Exercise>[];
      final uncachedIds = <String>[];

      // Check cache for each ID
      for (final id in exerciseIds) {
        if (_isCacheValid(id)) {
          exercises.add(_exerciseCache[id]!);
        } else {
          uncachedIds.add(id);
        }
      }

      // Fetch uncached exercises
      if (uncachedIds.isNotEmpty) {
        final response = await _supabaseClient
            .from('exercises')
            .select('*')
            .inFilter('id', uncachedIds)
            .eq('is_active', true);

        final fetchedExercises = (response as List)
            .map((json) => Exercise.fromMap(json))
            .toList();

        // Cache the fetched exercises
        for (final exercise in fetchedExercises) {
          _exerciseCache[exercise.id.toString()] = exercise;
          _cacheTimestamps[exercise.id.toString()] = DateTime.now();
        }

        exercises.addAll(fetchedExercises);
      }

      // Sort by the original order of exerciseIds
      exercises.sort((a, b) {
        final aIndex = exerciseIds.indexOf(a.id.toString());
        final bIndex = exerciseIds.indexOf(b.id.toString());
        return aIndex.compareTo(bIndex);
      });

      return exercises;
    });
  }

  @override
  Future<Either<Failure, List<Exercise>>> getPopularExercises({
    int? limit,
  }) async {
    return safeCall(() async {
      final cacheKey = 'popular_${limit ?? 'all'}';
      if (_isCacheValid(cacheKey)) {
        return _searchCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('*')
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .limit(limit ?? 20);

      final exercises = (response as List)
          .map((json) => Exercise.fromMap(json))
          .toList();

      // Cache the results
      _searchCache[cacheKey] = exercises;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return exercises;
    });
  }

  @override
  Future<Either<Failure, List<Exercise>>> getExercisesByCategory(
    String category, {
    int? limit,
  }) async {
    return safeCall(() async {
      final cacheKey = 'category_${category}_${limit ?? 'all'}';
      if (_isCacheValid(cacheKey)) {
        return _searchCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('*')
          .eq('category', category)
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .limit(limit ?? 20);

      final exercises = (response as List)
          .map((json) => Exercise.fromMap(json))
          .toList();

      // Cache the results
      _searchCache[cacheKey] = exercises;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return exercises;
    });
  }

  @override
  Future<Either<Failure, List<Exercise>>> getExercisesByMuscleGroup(
    String muscleGroup, {
    int? limit,
  }) async {
    return safeCall(() async {
      final cacheKey = 'muscle_${muscleGroup}_${limit ?? 'all'}';
      if (_isCacheValid(cacheKey)) {
        return _searchCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('*')
          .or(
            'primary_muscles_ko.cs.["$muscleGroup"],'
            'secondary_muscles_ko.cs.["$muscleGroup"],'
            'muscles_used_ko.cs.["$muscleGroup"]'
          )
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .limit(limit ?? 20);

      final exercises = (response as List)
          .map((json) => Exercise.fromMap(json))
          .toList();

      // Cache the results
      _searchCache[cacheKey] = exercises;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return exercises;
    });
  }

  @override
  Future<Either<Failure, List<Exercise>>> getExercisesByEquipment(
    String equipment, {
    int? limit,
  }) async {
    return safeCall(() async {
      final cacheKey = 'equipment_${equipment}_${limit ?? 'all'}';
      if (_isCacheValid(cacheKey)) {
        return _searchCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('*')
          .eq('equipment', equipment)
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .limit(limit ?? 20);

      final exercises = (response as List)
          .map((json) => Exercise.fromMap(json))
          .toList();

      // Cache the results
      _searchCache[cacheKey] = exercises;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return exercises;
    });
  }

  @override
  Future<Either<Failure, List<Exercise>>> getExercisesByDifficulty(
    String difficulty, {
    int? limit,
  }) async {
    return safeCall(() async {
      final cacheKey = 'difficulty_${difficulty}_${limit ?? 'all'}';
      if (_isCacheValid(cacheKey)) {
        return _searchCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('*')
          .eq('difficulty', difficulty)
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .limit(limit ?? 20);

      final exercises = (response as List)
          .map((json) => Exercise.fromMap(json))
          .toList();

      // Cache the results
      _searchCache[cacheKey] = exercises;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return exercises;
    });
  }

  @override
  Future<Either<Failure, List<String>>> getExerciseCategories() async {
    return safeCall(() async {
      const cacheKey = 'categories';
      if (_isCacheValid(cacheKey)) {
        return _stringListCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('category')
          .eq('is_active', true)
          .not('category', 'is', null);

      final categories = (response as List)
          .map((item) => item['category'] as String)
          .toSet()
          .toList()
        ..sort();

      // Cache the results
      _stringListCache[cacheKey] = categories;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return categories;
    });
  }

  @override
  Future<Either<Failure, List<String>>> getMuscleGroups() async {
    return safeCall(() async {
      const cacheKey = 'muscle_groups';
      if (_isCacheValid(cacheKey)) {
        return _stringListCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('primary_muscles_ko, secondary_muscles_ko, muscles_used_ko')
          .eq('is_active', true);

      final muscleGroups = <String>{};
      
      for (final item in response as List) {
        final primaryMuscles = _parseJsonList(item['primary_muscles_ko']);
        final secondaryMuscles = _parseJsonList(item['secondary_muscles_ko']);
        final musclesUsed = _parseJsonList(item['muscles_used_ko']);
        
        muscleGroups.addAll(primaryMuscles);
        muscleGroups.addAll(secondaryMuscles);
        muscleGroups.addAll(musclesUsed);
      }

      final sortedMuscleGroups = muscleGroups.toList()..sort();

      // Cache the results
      _stringListCache[cacheKey] = sortedMuscleGroups;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return sortedMuscleGroups;
    });
  }

  @override
  Future<Either<Failure, List<String>>> getEquipmentTypes() async {
    return safeCall(() async {
      const cacheKey = 'equipment_types';
      if (_isCacheValid(cacheKey)) {
        return _stringListCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('equipment')
          .eq('is_active', true)
          .not('equipment', 'is', null);

      final equipmentTypes = (response as List)
          .map((item) => item['equipment'] as String)
          .toSet()
          .toList()
        ..sort();

      // Cache the results
      _stringListCache[cacheKey] = equipmentTypes;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return equipmentTypes;
    });
  }

  @override
  Future<Either<Failure, List<String>>> getDifficultyLevels() async {
    return safeCall(() async {
      const cacheKey = 'difficulty_levels';
      if (_isCacheValid(cacheKey)) {
        return _stringListCache[cacheKey]!;
      }

      final response = await _supabaseClient
          .from('exercises')
          .select('difficulty')
          .eq('is_active', true)
          .not('difficulty', 'is', null);

      final difficultyLevels = (response as List)
          .map((item) => item['difficulty'] as String)
          .toSet()
          .toList()
        ..sort();

      // Cache the results
      _stringListCache[cacheKey] = difficultyLevels;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return difficultyLevels;
    });
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    return safeCall(() async {
      _exerciseCache.clear();
      _searchCache.clear();
      _stringListCache.clear();
      _cacheTimestamps.clear();
    });
  }

  @override
  Future<Either<Failure, void>> refreshCache() async {
    return safeCall(() async {
      // Clear existing cache
      _exerciseCache.clear();
      _searchCache.clear();
      _stringListCache.clear();
      _cacheTimestamps.clear();
      
      // Pre-load popular exercises to warm up the cache
      await getPopularExercises(limit: 50);
    });
  }

  /// Check if cache entry is still valid
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  /// Parse JSON list from database field
  static List<String> _parseJsonList(dynamic jsonString) {
    if (jsonString == null || jsonString == '') return [];
    try {
      if (jsonString is String) {
        final List<dynamic> parsed = json.decode(jsonString);
        return parsed.map((e) => e.toString()).toList();
      } else if (jsonString is List) {
        return jsonString.map((e) => e.toString()).toList();
      }
    } catch (e) {
      // Silently handle JSON parsing errors
    }
    return [];
  }
}