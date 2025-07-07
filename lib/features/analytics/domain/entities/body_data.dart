import 'package:equatable/equatable.dart';

class BodyData extends Equatable {
  final DateTime date;
  final double weight;
  final double muscleMass;
  final double bodyFat;

  const BodyData({
    required this.date,
    required this.weight,
    required this.muscleMass,
    required this.bodyFat,
  });

  @override
  List<Object> get props => [date, weight, muscleMass, bodyFat];

  // 호환성을 위한 getter
  String get dateLabel => '${date.month}/${date.day}';
  double get skeletalMuscleMass => muscleMass;
  double get bodyFatPercentage => bodyFat;
}
