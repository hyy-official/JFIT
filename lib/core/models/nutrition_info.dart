class NutritionInfo {
  String foodName;
  double servingSize; // g
  double totalSize; // g (deprecated, use weight instead)
  double calories;
  double carbs;
  double protein;
  double fat;
  String? foodItemId; // DB의 food_items 테이블 ID
  double? weight; // 실제 섭취한 중량 (g)

  NutritionInfo({
    this.foodName = '',
    this.servingSize = 100.0,
    this.totalSize = 100.0,
    this.calories = 0.0,
    this.carbs = 0.0,
    this.protein = 0.0,
    this.fat = 0.0,
    this.foodItemId,
    this.weight,
  });

  factory NutritionInfo.fromSearchResult(Map<String, dynamic> data) {
    return NutritionInfo(
      foodName: data['name'] ?? '',
      servingSize: (data['servingSize'] as num?)?.toDouble() ?? 100.0,
      totalSize: (data['totalSize'] as num?)?.toDouble() ?? 100.0,
      calories: (data['calories'] as num?)?.toDouble() ?? 0.0,
      carbs: (data['carbohydrates'] as num?)?.toDouble() ?? 0.0,
      protein: (data['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (data['fat'] as num?)?.toDouble() ?? 0.0,
      foodItemId: data['id']?.toString(),
      weight: (data['weight'] as num?)?.toDouble(),
    );
  }

  // Copy with method for easy modification
  NutritionInfo copyWith({
    String? foodName,
    double? servingSize,
    double? totalSize,
    double? calories,
    double? carbs,
    double? protein,
    double? fat,
    String? foodItemId,
    double? weight,
  }) {
    return NutritionInfo(
      foodName: foodName ?? this.foodName,
      servingSize: servingSize ?? this.servingSize,
      totalSize: totalSize ?? this.totalSize,
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      foodItemId: foodItemId ?? this.foodItemId,
      weight: weight ?? this.weight,
    );
  }

  bool get isValid => foodName.isNotEmpty && calories > 0;
}