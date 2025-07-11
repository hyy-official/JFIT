import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_program_day_model.g.dart';

@JsonSerializable()
class UserProgramDayModel extends Equatable {
  final String id;
  final String userProgramId;
  final int week;
  final int day;
  final DateTime? completedAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProgramDayModel({
    required this.id,
    required this.userProgramId,
    required this.week,
    required this.day,
    this.completedAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userProgramId,
    week,
    day,
    completedAt,
    note,
    createdAt,
    updatedAt,
  ];

  factory UserProgramDayModel.fromJson(Map<String, dynamic> json) =>
      _$UserProgramDayModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgramDayModelToJson(this);
} 