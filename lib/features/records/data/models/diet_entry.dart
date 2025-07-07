class DietEntry {
  String? imagePath;
  String foodName;
  List<String> mealTypes;
  String satisfaction;
  int? score;
  DateTime time;
  String memo;
  List<String> accompaniments;
  bool isBookmarked;
  double? calories;
  double? protein;
  double? carbs;
  double? fat;

  DietEntry({
    this.imagePath,
    this.foodName = '',
    List<String>? mealTypes,
    this.satisfaction = '',
    this.score,
    DateTime? time,
    this.memo = '',
    List<String>? accompaniments,
    this.isBookmarked = false,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  })  : mealTypes = mealTypes ?? [],
        accompaniments = accompaniments ?? [],
        time = time ?? DateTime.now();

  bool get isValid => foodName.isNotEmpty && mealTypes.isNotEmpty;
} 