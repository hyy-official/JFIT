import 'package:equatable/equatable.dart';

class WorkoutTimeData extends Equatable {
  final DateTime date;
  final double duration;

  const WorkoutTimeData({
    required this.date,
    required this.duration,
  });

  @override
  List<Object> get props => [date, duration];

  // 호환성을 위한 getter
  String get dateLabel => '${date.month}/${date.day}';
  double get minutes => duration;
} 