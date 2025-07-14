// lib/features/programs/domain/entities/workout_program.dart

import 'package:equatable/equatable.dart';

/// 순수 도메인 엔티티: 운동 프로그램의 메타데이터를 표현합니다.
///
/// presentation/data 계층 어디에서도 변경되지 않는 불변(immutable) 객체로 사용됩니다.
class WorkoutProgram extends Equatable {
  final String id;
  final String name;
  final String creator; // 프로그램 제작자 표시(닉네임 등)
  final String description;
  final int durationWeeks; // 총 진행 주차
  final String difficultyLevel; // beginner / intermediate / advanced 등
  final String programType; // strength / hypertrophy / etc.

  final int? workoutsPerWeek; // 주 당 운동 횟수 (nullable)
  final List<String>? equipmentNeeded; // 필요한 기구 목록 (nullable)
  final dynamic? weeklySchedule; // 예: [{"week": 1, "days": [...]}] 또는 {"mon": [...], "tue": [...]}
  final List<String>? tags; // 검색·필터 태그 (nullable)

  final double rating; // 평균 평점
  final int totalRatings; // 평점 참여 수
  final bool isPopular; // 인기 프로그램 여부 표시
  final bool isPublic; // 공개/비공개 플래그

  // 시스템/메타 정보
  final String? createdBy; // 작성자 UID (nullable)
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version; // 버전 관리용

  // UI 편의 필드
  final String? imageUrl; // 썸네일 이미지
  final bool isSample; // 샘플 데이터 여부

  const WorkoutProgram({
    required this.id,
    required this.name,
    required this.creator,
    required this.description,
    required this.durationWeeks,
    required this.difficultyLevel,
    required this.programType,
    this.workoutsPerWeek,
    this.equipmentNeeded,
    this.weeklySchedule,
    this.tags,
    required this.rating,
    required this.totalRatings,
    required this.isPopular,
    required this.isPublic,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.imageUrl,
    required this.isSample,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        creator,
        description,
        durationWeeks,
        difficultyLevel,
        programType,
        workoutsPerWeek,
        equipmentNeeded,
        weeklySchedule,
        tags,
        rating,
        totalRatings,
        isPopular,
        isPublic,
        createdBy,
        createdAt,
        updatedAt,
        version,
        imageUrl,
        isSample,
      ];

  WorkoutProgram copyWith({
    String? id,
    String? name,
    String? creator,
    String? description,
    int? durationWeeks,
    String? difficultyLevel,
    String? programType,
    int? workoutsPerWeek,
    List<String>? equipmentNeeded,
    dynamic? weeklySchedule,
    List<String>? tags,
    double? rating,
    int? totalRatings,
    bool? isPopular,
    bool? isPublic,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? imageUrl,
    bool? isSample,
  }) {
    return WorkoutProgram(
      id: id ?? this.id,
      name: name ?? this.name,
      creator: creator ?? this.creator,
      description: description ?? this.description,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      programType: programType ?? this.programType,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      equipmentNeeded: equipmentNeeded ?? this.equipmentNeeded,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      isPopular: isPopular ?? this.isPopular,
      isPublic: isPublic ?? this.isPublic,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      imageUrl: imageUrl ?? this.imageUrl,
      isSample: isSample ?? this.isSample,
    );
  }
} 