import 'package:equatable/equatable.dart';

class DietScoreData extends Equatable {
  final DateTime date;
  final double score;

  const DietScoreData({
    required this.date,
    required this.score,
  });

  @override
  List<Object> get props => [date, score];

  // 호환성을 위한 getter
  String get dateLabel => '${date.month}/${date.day}';
} 