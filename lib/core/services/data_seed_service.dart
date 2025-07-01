import 'package:uuid/uuid.dart';
import 'package:jfit/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DataSeedService {
  static final DataSeedService _instance = DataSeedService._internal();
  factory DataSeedService() => _instance;
  DataSeedService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  /// 샘플 데이터 삽입
  Future<void> seedSampleData() async {
    try {
      // 기존 샘플 데이터 확인
      final existingPrograms = await _dbHelper.getWorkoutPrograms();
      if (existingPrograms.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      // 샘플 사용자 생성
      await _seedSampleUser();
      
      // 음식 데이터 삽입
      await _seedFoodItems();
      
      // 운동 프로그램 삽입
      await _seedWorkoutPrograms();
      
      // 샘플 운동 기록 삽입
      await _seedExerciseRecords();
      
      // 샘플 식사 기록 삽입
      await _seedMealEntries();

      print('Sample data seeded successfully');
    } catch (e) {
      print('Error seeding sample data: $e');
    }
  }

  /// 샘플 사용자 생성
  Future<void> _seedSampleUser() async {
    final db = await _dbHelper.database;
    
    final user = {
      'id': 'sample-user-001',
      'email': 'sample@jfit.com',
      'name': '샘플 사용자',
      'created_date': DateTime.now().toIso8601String(),
      'updated_date': DateTime.now().toIso8601String(),
      'is_synced': 1,
    };

    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// 음식 데이터 삽입
  Future<void> _seedFoodItems() async {
    final foodItems = [
      {
        'id': _uuid.v4(),
        'name': '닭가슴살',
        'serving_size_g': 100.0,
        'calories': 165.0,
        'protein': 31.0,
        'carbohydrates': 0.0,
        'fat': 3.6,
        'is_sample': 1,
      },
      {
        'id': _uuid.v4(),
        'name': '현미밥',
        'serving_size_g': 100.0,
        'calories': 111.0,
        'protein': 2.6,
        'carbohydrates': 23.0,
        'fat': 0.9,
        'is_sample': 1,
      },
      {
        'id': _uuid.v4(),
        'name': '계란',
        'serving_size_g': 50.0,
        'calories': 78.0,
        'protein': 6.0,
        'carbohydrates': 0.6,
        'fat': 5.3,
        'is_sample': 1,
      },
      {
        'id': _uuid.v4(),
        'name': '브로콜리',
        'serving_size_g': 100.0,
        'calories': 34.0,
        'protein': 2.8,
        'carbohydrates': 7.0,
        'fat': 0.4,
        'is_sample': 1,
      },
      {
        'id': _uuid.v4(),
        'name': '바나나',
        'serving_size_g': 100.0,
        'calories': 89.0,
        'protein': 1.1,
        'carbohydrates': 23.0,
        'fat': 0.3,
        'is_sample': 1,
      },
    ];

    for (final foodItem in foodItems) {
      await _dbHelper.insertFoodItem(foodItem);
    }
  }

  /// 운동 프로그램 삽입
  Future<void> _seedWorkoutPrograms() async {
    final programs = [
      {
        'id': _uuid.v4(),
        'name': 'StrongLifts 5x5',
        'creator': 'Mehdi Hadim',
        'description': '초보자를 위한 가장 인기 있는 근력 운동 프로그램입니다. 간단하고 효과적이며 근력과 근육량 증가가 입증된 프로그램입니다.',
        'duration_weeks': 12,
        'difficulty_level': 'beginner',
        'program_type': 'strength',
        'workouts_per_week': 3,
        'equipment_needed': ['바벨', '웨이트 플레이트', '스쿼트 랙', '벤치'],
        'weekly_schedule': [
          {
            'week': 1,
            'days': [
              {
                'name': 'Day A',
                'exercises': [
                  {
                    'name': '스쿼트',
                    'sets': 5,
                    'reps': '5',
                    'notes': '무릎이 발끝을 넘지 않도록 주의'
                  },
                  {
                    'name': '벤치프레스',
                    'sets': 5,
                    'reps': '5',
                    'notes': '어깨 블레이드를 모으고 수행'
                  },
                  {
                    'name': '바벨로우',
                    'sets': 5,
                    'reps': '5',
                    'notes': '등 근육을 의식하며 당기기'
                  }
                ]
              },
              {
                'name': 'Day B',
                'exercises': [
                  {
                    'name': '스쿼트',
                    'sets': 5,
                    'reps': '5',
                    'notes': '무릎이 발끝을 넘지 않도록 주의'
                  },
                  {
                    'name': '오버헤드프레스',
                    'sets': 5,
                    'reps': '5',
                    'notes': '코어를 단단히 유지'
                  },
                  {
                    'name': '데드리프트',
                    'sets': 1,
                    'reps': '5',
                    'notes': '허리를 곧게 펴고 수행'
                  }
                ]
              }
            ]
          }
        ],
        'tags': ['초급', '근력', '복합운동'],
        'rating': 4.8,
        'is_popular': 1,
        'is_sample': 1,
      },
      {
        'id': _uuid.v4(),
        'name': 'Push Pull Legs',
        'creator': 'Jeff Nippard',
        'description': '푸시 근육(가슴, 어깨, 삼두), 풀 근육(등, 이두), 다리로 나눈 6일 분할 운동입니다. 중급자부터 고급자까지 적합합니다.',
        'duration_weeks': 8,
        'difficulty_level': 'intermediate',
        'program_type': 'hypertrophy',
        'workouts_per_week': 6,
        'equipment_needed': ['바벨', '덤벨', '케이블 머신', '풀업바'],
        'weekly_schedule': [
          {
            'week': 1,
            'days': [
              {
                'name': 'Push Day',
                'exercises': [
                  {
                    'name': '벤치프레스',
                    'sets': 4,
                    'reps': '6-8',
                    'notes': '가슴 근육에 집중'
                  },
                  {
                    'name': '인클라인 덤벨프레스',
                    'sets': 3,
                    'reps': '8-10',
                    'notes': '상부 가슴 발달'
                  },
                  {
                    'name': '딥스',
                    'sets': 3,
                    'reps': '10-12',
                    'notes': '몸을 약간 앞으로 기울이기'
                  },
                  {
                    'name': '래터럴 레이즈',
                    'sets': 4,
                    'reps': '12-15',
                    'notes': '어깨 측면 집중'
                  }
                ]
              }
            ]
          }
        ],
        'tags': ['중급', '근비대', '분할운동'],
        'rating': 4.6,
        'is_popular': 1,
        'is_sample': 1,
      },
      {
        'id': _uuid.v4(),
        'name': '초보자 근력 성장 프로그램',
        'creator': 'Arnold Schwarzenegger',
        'description': '헬스 초보자를 위한 전신 근력 강화 프로그램입니다. 기본적인 다관절 운동 위주로 구성되어 있습니다.',
        'duration_weeks': 8,
        'difficulty_level': 'beginner',
        'program_type': 'strength',
        'workouts_per_week': 3,
        'equipment_needed': ['바벨', '덤벨', '벤치'],
        'weekly_schedule': [
          {
            'week': 1,
            'days': [
              {
                'name': 'Day 1: 전신 A',
                'exercises': [
                  {
                    'name': '스쿼트',
                    'sets': 5,
                    'reps': '5',
                    'notes': '자세에 집중'
                  },
                  {
                    'name': '벤치프레스',
                    'sets': 5,
                    'reps': '5',
                    'notes': null
                  },
                  {
                    'name': '바벨로우',
                    'sets': 5,
                    'reps': '5',
                    'notes': null
                  }
                ]
              },
              {
                'name': 'Day 2: 휴식',
                'exercises': []
              },
              {
                'name': 'Day 3: 전신 B',
                'exercises': [
                  {
                    'name': '데드리프트',
                    'sets': 3,
                    'reps': '5',
                    'notes': null
                  },
                  {
                    'name': '오버헤드 프레스',
                    'sets': 5,
                    'reps': '5',
                    'notes': null
                  },
                  {
                    'name': '풀업',
                    'sets': 5,
                    'reps': '실패지점까지',
                    'notes': null
                  }
                ]
              }
            ]
          }
        ],
        'tags': ['초보자', '근력', '전신'],
        'rating': 4.5,
        'is_popular': 1,
        'is_sample': 1,
      }
    ];

    for (final program in programs) {
      await _dbHelper.insertWorkoutProgram(program);
    }
  }

  /// 샘플 운동 기록 삽입
  Future<void> _seedExerciseRecords() async {
    final exercises = [
      {
        'id': _uuid.v4(),
        'user_id': 'sample-user-001',
        'exercise_name': '벤치프레스',
        'exercise_type': 'strength',
        'duration_minutes': 60,
        'calories_burned': 300,
        'intensity': 'high',
        'exercise_date': '2024-05-20',
        'weight': 80.0,
        'sets': 3,
        'reps': 8,
        'notes': 'PR 달성!',
        'is_synced': 1,
      },
      {
        'id': _uuid.v4(),
        'user_id': 'sample-user-001',
        'exercise_name': '달리기',
        'exercise_type': 'cardio',
        'duration_minutes': 30,
        'calories_burned': 350,
        'intensity': 'moderate',
        'exercise_date': '2024-05-21',
        'notes': '한강에서 상쾌하게',
        'is_synced': 1,
      },
      {
        'id': _uuid.v4(),
        'user_id': 'sample-user-001',
        'exercise_name': '스쿼트',
        'exercise_type': 'strength',
        'duration_minutes': 70,
        'calories_burned': 400,
        'intensity': 'high',
        'exercise_date': '2024-05-22',
        'weight': 100.0,
        'sets': 5,
        'reps': 5,
        'notes': '하체 집중',
        'is_synced': 1,
      },
      {
        'id': _uuid.v4(),
        'user_id': 'sample-user-001',
        'exercise_name': '요가',
        'exercise_type': 'flexibility',
        'duration_minutes': 45,
        'calories_burned': 150,
        'intensity': 'low',
        'exercise_date': '2024-05-23',
        'is_synced': 1,
      },
      {
        'id': _uuid.v4(),
        'user_id': 'sample-user-001',
        'exercise_name': '데드리프트',
        'exercise_type': 'strength',
        'duration_minutes': 60,
        'calories_burned': 380,
        'intensity': 'high',
        'exercise_date': '2024-05-24',
        'weight': 120.0,
        'sets': 3,
        'reps': 5,
        'is_synced': 1,
      }
    ];

    for (final exercise in exercises) {
      await _dbHelper.insertExercise(exercise);
    }
  }

  /// 샘플 식사 기록 삽입
  Future<void> _seedMealEntries() async {
    // 먼저 음식 아이템들을 가져와서 ID를 얻습니다
    final foodItems = await _dbHelper.getFoodItems();
    
    if (foodItems.isEmpty) return;

    final mealEntries = [
      {
        'id': _uuid.v4(),
        'user_id': 'sample-user-001',
        'food_item_id': foodItems[0]['id'], // 닭가슴살
        'food_name': '닭가슴살',
        'meal_type': 'lunch',
        'quantity_g': 200.0,
        'entry_date': '2024-05-27',
        'calories': 330.0,
        'protein': 62.0,
        'carbohydrates': 0.0,
        'fat': 7.2,
        'is_synced': 1,
      },
      {
        'id': _uuid.v4(),
        'user_id': 'sample-user-001',
        'food_item_id': foodItems[1]['id'], // 현미밥
        'food_name': '현미밥',
        'meal_type': 'lunch',
        'quantity_g': 150.0,
        'entry_date': '2024-05-27',
        'calories': 167.0,
        'protein': 3.9,
        'carbohydrates': 34.5,
        'fat': 1.4,
        'is_synced': 1,
      },
      {
        'id': _uuid.v4(),
        'user_id': 'sample-user-001',
        'food_item_id': foodItems[2]['id'], // 계란
        'food_name': '계란 (삶은 것)',
        'meal_type': 'breakfast',
        'quantity_g': 100.0,
        'entry_date': '2024-05-27',
        'calories': 154.0,
        'protein': 12.0,
        'carbohydrates': 1.2,
        'fat': 10.0,
        'is_synced': 1,
      }
    ];

    for (final mealEntry in mealEntries) {
      await _dbHelper.insertMealEntry(mealEntry);
    }
  }

  /// 데이터베이스 초기화 (개발용)
  Future<void> clearAllData() async {
    await _dbHelper.clearDatabase();
    print('All data cleared');
  }
} 