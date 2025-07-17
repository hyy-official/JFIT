import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/features/meal/data/repositories/meal_repository.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealRepositoryImpl extends MealRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;

  MealRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<MealRecord>>> getMealRecords(
    String userId, {
    DateTime? date,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('user_meal_entries')
          .select('*')
          .eq('user_id', userId);

      if (date != null) {
        query = query.eq('entry_date', date.toIso8601String().split('T')[0]);
      }

      final response = await query.order('entry_date', ascending: false);

      return (response as List)
          .map((json) => _mapToMealRecord(json))
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> addMealRecord(MealRecord record) async {
    debugPrint('🗄️ MealRepository: Starting to add meal record');
    debugPrint('🗄️ MealRepository: Record ID: ${record.id}');
    debugPrint('🗄️ MealRepository: User ID: ${record.userId}');
    debugPrint('🗄️ MealRepository: Meal Type: ${record.mealType}');
    
    return safeCall(() async {
      final mappedData = _mapFromMealRecord(record);
      debugPrint('🗄️ MealRepository: Mapped data: $mappedData');
      
      debugPrint('🔄 MealRepository: Calling Supabase insert...');
      final result = await _supabaseClient
          .from('user_meal_entries')
          .insert(mappedData);
      
      debugPrint('✅ MealRepository: Supabase insert completed');
      debugPrint('✅ MealRepository: Result: $result');
    });
  }

  @override
  Future<Either<Failure, void>> updateMealRecord(MealRecord record) async {
    return safeCall(() async {
      await _supabaseClient
          .from('user_meal_entries')
          .update(_mapFromMealRecord(record))
          .eq('id', record.id);
    });
  }

  @override
  Future<Either<Failure, void>> deleteMealRecord(String recordId) async {
    return safeCall(() async {
      await _supabaseClient
          .from('user_meal_entries')
          .delete()
          .eq('id', recordId);
    });
  }

  /// Map database record to MealRecord model
  MealRecord _mapToMealRecord(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mealDate: DateTime.parse(json['entry_date'] as String),
      mealType: json['meal_type'] as String,
      totalCalories: (json['calories'] as num?)?.toDouble(),
      totalProtein: (json['protein_g'] as num?)?.toDouble(),
      totalCarbs: (json['carbohydrate_g'] as num?)?.toDouble(),
      totalFat: (json['fat_g'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  /// Map MealRecord model to database record
  Map<String, dynamic> _mapFromMealRecord(MealRecord record) {
    return {
      'id': record.id,
      'user_id': record.userId,
      'entry_date': record.mealDate.toIso8601String().split('T')[0],
      'meal_type': record.mealType,
      'calories': record.totalCalories,
      'protein_g': record.totalProtein,
      'carbohydrate_g': record.totalCarbs,
      'fat_g': record.totalFat,
      'notes': record.notes,
      'photo_url': record.photoUrl,
    };
  }
}