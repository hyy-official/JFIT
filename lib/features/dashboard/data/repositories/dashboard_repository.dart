import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

class DashboardRepository {
  // 더미 데이터 (실제로는 Supabase와 통신)
  final List<UserDailySummary> _mockDailySummaries = [
    UserDailySummary(
      id: 'summary_20240701',
      userId: 1,
      summaryDate: DateTime(2024, 7, 1),
      totalWorkoutDurationMinutes: 30,
      totalCaloriesBurned: 200,
      totalCaloriesConsumed: 1800.0,
      totalProteinConsumed: 100.0,
      totalCarbsConsumed: 200.0,
      totalFatConsumed: 70.0,
    ),
    UserDailySummary(
      id: 'summary_20240702',
      userId: 1,
      summaryDate: DateTime(2024, 7, 2),
      totalWorkoutDurationMinutes: 45,
      totalCaloriesBurned: 300,
      totalCaloriesConsumed: 2000.0,
      totalProteinConsumed: 120.0,
      totalCarbsConsumed: 250.0,
      totalFatConsumed: 80.0,
    ),
    UserDailySummary(
      id: 'summary_20240703',
      userId: 1,
      summaryDate: DateTime(2024, 7, 3),
      totalWorkoutDurationMinutes: 60,
      totalCaloriesBurned: 400,
      totalCaloriesConsumed: 2200.0,
      totalProteinConsumed: 130.0,
      totalCarbsConsumed: 280.0,
      totalFatConsumed: 90.0,
    ),
  ];

  Future<List<UserDailySummary>> getDailySummaries(int userId, {DateTime? startDate, DateTime? endDate}) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    // TODO: Supabase에서 userId와 날짜 범위에 해당하는 일일 요약 조회 로직 구현
    return _mockDailySummaries.where((summary) {
      bool matchesUser = summary.userId == userId;
      bool matchesStartDate = startDate == null || !summary.summaryDate.isBefore(startDate);
      bool matchesEndDate = endDate == null || !summary.summaryDate.isAfter(endDate);
      return matchesUser && matchesStartDate && matchesEndDate;
    }).toList();
  }
}
