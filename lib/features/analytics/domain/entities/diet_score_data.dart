class DietScoreData {
  final String dateLabel; // X축 라벨 (예: '월', '07/15')
  final double score;     // Y축 값 (1.0 ~ 5.0)

  DietScoreData({required this.dateLabel, required this.score});
} 