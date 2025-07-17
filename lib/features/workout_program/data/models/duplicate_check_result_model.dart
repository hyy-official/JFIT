import 'package:equatable/equatable.dart';
import '../../../../core/error/workout_program_failures.dart';

/// 중복 체크 결과를 나타내는 모델
class DuplicateCheckResult extends Equatable {
  final bool isDuplicate;
  final String? existingProgramId;
  final ProgramStatus? status;
  final double? progressPercent;
  final ProgramDuplicateInfo? duplicateInfo;

  const DuplicateCheckResult({
    required this.isDuplicate,
    this.existingProgramId,
    this.status,
    this.progressPercent,
    this.duplicateInfo,
  });

  /// 중복이 없는 경우의 팩토리 생성자
  const DuplicateCheckResult.noDuplicate()
      : isDuplicate = false,
        existingProgramId = null,
        status = null,
        progressPercent = null,
        duplicateInfo = null;

  /// 중복이 있는 경우의 팩토리 생성자
  DuplicateCheckResult.duplicate({
    required String existingProgramId,
    required ProgramDuplicateInfo duplicateInfo,
  })  : isDuplicate = true,
        existingProgramId = existingProgramId,
        status = duplicateInfo.status,
        progressPercent = duplicateInfo.progressPercent,
        duplicateInfo = duplicateInfo;

  /// Map에서 DuplicateCheckResult 생성
  factory DuplicateCheckResult.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const DuplicateCheckResult.noDuplicate();
    }

    final userProgramId = map['userProgramId'] as String;
    final programName = map['programName'] as String;
    final currentWeek = map['currentWeek'] as int? ?? 1;
    final currentDay = map['currentDay'] as int? ?? 1;
    final totalWeeks = map['totalWeeks'] as int? ?? 1;
    final progressPercent = (map['progressPercent'] as num?)?.toDouble() ?? 0.0;
    final isCompleted = map['isCompleted'] as bool? ?? false;
    final startedAtString = map['startedAt'] as String?;
    final startedAt = startedAtString != null ? DateTime.tryParse(startedAtString) : null;

    // 상태 결정
    ProgramStatus status;
    if (isCompleted) {
      status = ProgramStatus.completed;
    } else if (progressPercent > 0) {
      status = ProgramStatus.active;
    } else {
      status = ProgramStatus.paused;
    }

    // 사용 가능한 옵션 결정
    List<ResolutionOption> availableOptions;
    if (isCompleted) {
      availableOptions = [
        ResolutionOption.restartProgram,
        ResolutionOption.createNewInstance,
        ResolutionOption.cancel,
      ];
    } else {
      availableOptions = [
        ResolutionOption.continueExisting,
        ResolutionOption.restartProgram,
        ResolutionOption.createNewInstance,
        ResolutionOption.cancel,
      ];
    }

    final duplicateInfo = ProgramDuplicateInfo(
      userProgramId: userProgramId,
      programName: programName,
      currentWeek: currentWeek,
      currentDay: currentDay,
      totalWeeks: totalWeeks,
      progressPercent: progressPercent,
      isCompleted: isCompleted,
      startedAt: startedAt,
      status: status,
      availableOptions: availableOptions,
    );

    return DuplicateCheckResult.duplicate(
      existingProgramId: userProgramId,
      duplicateInfo: duplicateInfo,
    );
  }

  @override
  List<Object?> get props => [
        isDuplicate,
        existingProgramId,
        status,
        progressPercent,
        duplicateInfo,
      ];
}