import 'package:jfit/features/exercise/data/models/exercise_record.dart';

class ExerciseRepository {
  // 더미 데이터 (실제로는 Supabase와 통신)
  final List<ExerciseRecord> _mockRecords = [
    const ExerciseRecord(
      id: '1',
      userId: 1,
      exerciseName: '스쿼트',
      exerciseType: 'strength',
      durationMinutes: 40,
      caloriesBurned: 270,
      exerciseDate: DateTime(2024, 12, 6),
      weightKg: 80.0,
      sets: 3,
      reps: 12,
    ),
    const ExerciseRecord(
      id: '2',
      userId: 1,
      exerciseName: '벤치프레스',
      exerciseType: 'strength',
      durationMinutes: 45,
      caloriesBurned: 220,
      exerciseDate: DateTime(2024, 12, 5),
      weightKg: 70.0,
      sets: 4,
      reps: 10,
    ),
    const ExerciseRecord(
      id: '3',
      userId: 1,
      exerciseName: '달리기',
      exerciseType: 'cardio',
      durationMinutes: 30,
      caloriesBurned: 250,
      exerciseDate: DateTime(2024, 12, 4),
      distanceKm: 5.0,
    ),
  ];

  Future<List<ExerciseRecord>> getExerciseRecords(int userId) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    // TODO: Supabase에서 userId에 해당하는 운동 기록 조회 로직 구현
    return _mockRecords.where((record) => record.userId == userId).toList();
  }

  Future<ExerciseRecord> addExerciseRecord(ExerciseRecord record) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    // TODO: Supabase에 운동 기록 추가 로직 구현
    // _mockRecords.add(record); // 실제 DB에서는 ID가 자동 생성됨
    return record;
  }

  Future<ExerciseRecord> updateExerciseRecord(ExerciseRecord record) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    // TODO: Supabase에서 운동 기록 업데이트 로직 구현
    final index = _mockRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _mockRecords[index] = record;
    }
    return record;
  }

  Future<void> deleteExerciseRecord(String recordId) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    // TODO: Supabase에서 운동 기록 삭제 로직 구현
    _mockRecords.removeWhere((record) => record.id == recordId);
  }
}
