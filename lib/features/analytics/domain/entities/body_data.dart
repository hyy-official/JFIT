import 'package:equatable/equatable.dart';

class BodyData extends Equatable {
  final String dateLabel;
  final double weight;
  final double skeletalMuscleMass;
  final double bodyFatPercentage;

  const BodyData({
    required this.dateLabel,
    required this.weight,
    required this.skeletalMuscleMass,
    required this.bodyFatPercentage,
  });

  @override
  List<Object> get props => [dateLabel, weight, skeletalMuscleMass, bodyFatPercentage];
}
