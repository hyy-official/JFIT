import 'nutrition_info.dart';

class FoodSearchItem {
  final String id;
  final String foodName;
  final String? brandName;
  final String servingDescription;
  final double calories;
  final double standardSizeG;
  final double totalSizeG;
  final Map<String, dynamic> fullNutritionData;

  FoodSearchItem({
    required this.id,
    required this.foodName,
    this.brandName,
    required this.servingDescription,
    required this.calories,
    required this.standardSizeG,
    required this.totalSizeG,
    required this.fullNutritionData,
  });

  factory FoodSearchItem.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    return FoodSearchItem(
      id: json['id'] ?? '',
      foodName: json['name'] ?? json['foodName'] ?? '',
      brandName: json['brand'] ?? json['brandName'],
      servingDescription: '총량 ${(json['total_size_g'] ?? json['standard_size_g'] ?? 100).toString()}g',
      calories: _toDouble(json['energy_kcal']),
      standardSizeG: _toDouble(json['standard_size_g']) == 0 ? 100.0 : _toDouble(json['standard_size_g']),
      totalSizeG: _toDouble(json['total_size_g']) != 0
          ? _toDouble(json['total_size_g'])
          : _toDouble(json['standard_size_g']) != 0
              ? _toDouble(json['standard_size_g'])
              : 100.0,
      fullNutritionData: json,
    );
  }

  NutritionInfo toNutritionInfo() {
    return NutritionInfo(
      foodName: foodName,
      servingSize: standardSizeG,
      totalSize: totalSizeG,
      calories: caloriesStandard,
      carbs: carbsStandard,
      protein: proteinStandard,
      fat: fatStandard,
      foodItemId: id,
      weight: totalSizeG,
    );
  }

  double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  double get _proteinStd => _d(fullNutritionData['protein_g']);
  double get _carbStd => _d(fullNutritionData['carbohydrate_g']);
  double get _fatStd => _d(fullNutritionData['fat_g']);

  double get caloriesPer100g => standardSizeG > 0 ? calories / standardSizeG * 100 : 0.0;
  double get caloriesTotal => standardSizeG > 0 ? calories * totalSizeG / standardSizeG : calories;

  double get proteinPer100g => standardSizeG > 0 ? _proteinStd / standardSizeG * 100 : 0.0;
  double get proteinTotal => standardSizeG > 0 ? _proteinStd * totalSizeG / standardSizeG : _proteinStd;

  double get carbsPer100g => standardSizeG > 0 ? _carbStd / standardSizeG * 100 : 0.0;
  double get carbsTotal => standardSizeG > 0 ? _carbStd * totalSizeG / standardSizeG : _carbStd;

  double get fatPer100g => standardSizeG > 0 ? _fatStd / standardSizeG * 100 : 0.0;
  double get fatTotal => standardSizeG > 0 ? _fatStd * totalSizeG / standardSizeG : _fatStd;

  // 표준량(standard_size_g) 기준 값 게터
  double get caloriesStandard => calories;
  double get proteinStandard => _proteinStd;
  double get carbsStandard => _carbStd;
  double get fatStandard => _fatStd;
}