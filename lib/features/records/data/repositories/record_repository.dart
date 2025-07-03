import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

class RecordRepository {
  // 더미 데이터 (실제로는 Supabase와 통신)
  final List<MealRecord> _mockMealRecords = [
    MealRecord(
      id: 'meal1',
      userId: 1,
      mealDate: DateTime(2024, 7, 3),
      mealType: 'breakfast',
      totalCalories: 500.0,
      totalProtein: 30.0,
      totalCarbs: 50.0,
      totalFat: 20.0,
      notes: '오트밀과 과일',
    ),
    MealRecord(
      id: 'meal2',
      userId: 1,
      mealDate: DateTime(2024, 7, 3),
      mealType: 'lunch',
      totalCalories: 700.0,
      totalProtein: 40.0,
      totalCarbs: 70.0,
      totalFat: 30.0,
      notes: '닭가슴살 샐러드',
    ),
  ];

  final List<UserDailySummary> _mockDailySummaries = [
    UserDailySummary(
      id: 'summary1',
      userId: 1,
      summaryDate: DateTime(2024, 7, 3),
      totalWorkoutDurationMinutes: 60,
      totalCaloriesBurned: 400,
      totalCaloriesConsumed: 1200.0,
      totalProteinConsumed: 70.0,
      totalCarbsConsumed: 120.0,
      totalFatConsumed: 50.0,
    ),
  ];

  Future<List<MealRecord>> getMealRecords(int userId, {DateTime? date}) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockMealRecords.where((record) {
      bool matchesUser = record.userId == userId;
      bool matchesDate = date == null ||
          (record.mealDate.year == date.year &&
              record.mealDate.month == date.month &&
              record.mealDate.day == date.day);
      return matchesUser && matchesDate;
    }).toList();
  }

  Future<MealRecord> addMealRecord(MealRecord record) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Supabase에 식사 기록 추가 로직 구현
    // _mockMealRecords.add(record); // 실제 DB에서는 ID가 자동 생성됨
    return record;
  }

  Future<MealRecord> updateMealRecord(MealRecord record) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Supabase에서 식사 기록 업데이트 로직 구현
    final index = _mockMealRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _mockMealRecords[index] = record;
    }
    return record;
  }

  Future<void> deleteMealRecord(String recordId) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Supabase에서 식사 기록 삭제 로직 구현
    _mockMealRecords.removeWhere((record) => record.id == recordId);
  }

  Future<UserDailySummary?> getDailySummary(int userId, DateTime date) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Supabase에서 userId와 date에 해당하는 일일 요약 조회 로직 구현
    return _mockDailySummaries.firstWhere(
      (summary) =>
          summary.userId == userId &&
          summary.summaryDate.year == date.year &&
          summary.summaryDate.month == date.month &&
          summary.summaryDate.day == date.day,
      orElse: () => UserDailySummary(
        id: 'new_summary',
        userId: userId,
        summaryDate: date,
      ),
    );
  }
}
