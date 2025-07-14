import 'dart:convert';

class Exercise {
  final int id;
  final String titleKo;
  final String? titleEn;
  final String descKo;
  final String? descEn;
  final String difficulty;
  final String difficultyKo;
  final String type;
  final String typeKo;
  final String equipment;
  final String equipmentKo;
  final List<String> primaryMusclesKo;
  final List<String> secondaryMusclesKo;
  final List<String> musclesUsedKo;
  final double? caloriesPerMinute;
  final double? metValue;
  final String? instructions;
  final List<String>? tips;
  final String? commonMistakes;
  final String? category;
  final List<String>? tags;
  final String? recommendedSets;
  final String? recommendedReps;
  final int? recommendedRestSeconds;
  final bool isActive;
  final bool isPartnerExercise;
  final int popularityScore;

  Exercise({
    required this.id,
    required this.titleKo,
    this.titleEn,
    required this.descKo,
    this.descEn,
    required this.difficulty,
    required this.difficultyKo,
    required this.type,
    required this.typeKo,
    required this.equipment,
    required this.equipmentKo,
    required this.primaryMusclesKo,
    required this.secondaryMusclesKo,
    required this.musclesUsedKo,
    this.caloriesPerMinute,
    this.metValue,
    this.instructions,
    this.tips,
    this.commonMistakes,
    this.category,
    this.tags,
    this.recommendedSets,
    this.recommendedReps,
    this.recommendedRestSeconds,
    this.isActive = true,
    this.isPartnerExercise = false,
    this.popularityScore = 0,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? 0,
      titleKo: map['title_ko'] ?? '',
      titleEn: map['title_en'],
      descKo: map['desc_ko'] ?? '',
      descEn: map['desc_en'],
      difficulty: map['difficulty'] ?? '',
      difficultyKo: map['difficulty_ko'] ?? '',
      type: map['type'] ?? '',
      typeKo: map['type_ko'] ?? '',
      equipment: map['equipment'] ?? '',
      equipmentKo: map['equipment_ko'] ?? '',
      primaryMusclesKo: _parseJsonList(map['primary_muscles_ko']),
      secondaryMusclesKo: _parseJsonList(map['secondary_muscles_ko']),
      musclesUsedKo: _parseJsonList(map['muscles_used_ko']),
      caloriesPerMinute: map['calories_per_minute']?.toDouble(),
      metValue: map['met_value']?.toDouble(),
      instructions: map['instructions'],
      tips: _parseJsonList(map['tips']),
      commonMistakes: map['common_mistakes'],
      category: map['category'],
      tags: _parseJsonList(map['tags']),
      recommendedSets: map['recommended_sets'],
      recommendedReps: map['recommended_reps'],
      recommendedRestSeconds: map['recommended_rest_seconds']?.toInt(),
      isActive: (map['is_active'] ?? 1) == 1,
      isPartnerExercise: (map['is_partner_exercise'] ?? 0) == 1,
      popularityScore: (map['popularity_score'] ?? 0).toInt(),
    );
  }

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
      print('JSON 파싱 오류: $e, 입력값: $jsonString');
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title_ko': titleKo,
      'title_en': titleEn,
      'desc_ko': descKo,
      'desc_en': descEn,
      'difficulty': difficulty,
      'difficulty_ko': difficultyKo,
      'type': type,
      'type_ko': typeKo,
      'equipment': equipment,
      'equipment_ko': equipmentKo,
      'primary_muscles_ko': json.encode(primaryMusclesKo),
      'secondary_muscles_ko': json.encode(secondaryMusclesKo),
      'muscles_used_ko': json.encode(musclesUsedKo),
      'calories_per_minute': caloriesPerMinute,
      'met_value': metValue,
      'instructions': instructions,
      'tips': tips != null ? json.encode(tips) : null,
      'common_mistakes': commonMistakes,
      'category': category,
      'tags': tags != null ? json.encode(tags) : null,
      'recommended_sets': recommendedSets,
      'recommended_reps': recommendedReps,
      'recommended_rest_seconds': recommendedRestSeconds,
      'is_active': isActive ? 1 : 0,
      'is_partner_exercise': isPartnerExercise ? 1 : 0,
      'popularity_score': popularityScore,
    };
  }

  @override
  String toString() {
    return 'Exercise{id: $id, titleKo: $titleKo, equipmentKo: $equipmentKo, difficultyKo: $difficultyKo}';
  }
} 