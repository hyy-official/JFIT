import 'package:equatable/equatable.dart';

class WorkoutCompositionData extends Equatable {
  final String category; // ex) 웨이트, 유산소 등
  final double value;
  final int color;

  const WorkoutCompositionData({
    required this.category,
    required this.value,
    required this.color,
  });

  @override
  List<Object> get props => [category, value, color];

  // 호환성을 위한 getter
  double get minutes => value;
} 