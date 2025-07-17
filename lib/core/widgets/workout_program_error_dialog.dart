import 'package:flutter/material.dart';
import '../theme/theme_system.dart';
import '../error/bloc_errors.dart';
import '../error/workout_program_failures.dart';
import 'enhanced_error_feedback.dart';

/// Specialized error dialog for workout program related errors
class WorkoutProgramErrorDialog {
  /// Show comprehensive error dialog for workout program failures
  static Future<T?> showWorkoutProgramError<T>(
    BuildContext context, {
    required String title,
    required String message,
    WorkoutProgramFailure? failure,
    List<WorkoutProgramErrorAction> actions = const [],
    bool barrierDismissible = true,
  }) {
    final colors = context.colors;
    
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _getErrorIcon(failure?.type),
              color: colors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (failure != null) ...[
              const SizedBox(height: 16),
              _buildErrorDetails(context, failure),
            ],
          ],
        ),
        actions: actions.isEmpty
            ? [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]
            : actions
                .map((action) => _buildDialogAction(context, action))
                .toList(),
      ),
    );
  }

  /// Show duplicate program resolution dialog
  static Future<ResolutionOption?> showDuplicateResolutionDialog(
    BuildContext context, {
    required String programName,
    required int currentWeek,
    required int currentDay,
    required double progressPercent,
    required bool isCompleted,
  }) {
    final colors = context.colors;
    
    return showDialog<ResolutionOption>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.content_copy,
              color: colors.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '중복 프로그램 발견',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '프로그램: $programName',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.success.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: colors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '축하합니다! 이미 완료한 프로그램입니다',
                        style: TextStyle(
                          color: colors.success,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: colors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '현재 진행 중인 프로그램입니다',
                          style: TextStyle(
                            color: colors.info,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '진행 상황: ${currentWeek}주차 ${currentDay}일차 (${progressPercent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? '다시 도전하시겠습니까?' : '어떻게 진행하시겠습니까?',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(ResolutionOption.cancel),
            child: Text(
              '취소',
              style: TextStyle(
                color: colors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!isCompleted)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(ResolutionOption.continueExisting),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.success,
                foregroundColor: colors.onSuccess,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('이어서 하기'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(ResolutionOption.restartProgram),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isCompleted ? '다시 도전하기' : '처음부터 하기'),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog with retry option for error recovery
  static Future<T?> showErrorRecoveryDialog<T>(
    BuildContext context, {
    required String message,
    required Future<void> Function() recoveryAction,
    String? successMessage,
    String? failureMessage,
  }) async {
    final colors = context.colors;
    
    // Show loading dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: colors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // Execute recovery action
      await recoveryAction();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      if (successMessage != null) {
        EnhancedErrorFeedback.showSuccessSnackBar(
          context,
          message: successMessage,
        );
      }
      
      return null;
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      EnhancedErrorFeedback.showErrorSnackBar(
        context,
        message: failureMessage ?? '복구 작업에 실패했습니다: $e',
        isRetryable: false,
      );
      
      return null;
    }
  }

  static IconData _getErrorIcon(WorkoutProgramErrorType? type) {
    switch (type) {
      case WorkoutProgramErrorType.networkError:
        return Icons.wifi_off;
      case WorkoutProgramErrorType.serverError:
        return Icons.cloud_off;
      case WorkoutProgramErrorType.repositoryNotInitialized:
        return Icons.settings_backup_restore;
      case WorkoutProgramErrorType.dataParsingError:
        return Icons.data_usage_off;
      case WorkoutProgramErrorType.duplicate:
        return Icons.content_copy;
      case WorkoutProgramErrorType.permissionDenied:
        return Icons.lock_outline;
      case WorkoutProgramErrorType.programNotFound:
        return Icons.search_off;
      case WorkoutProgramErrorType.exerciseDataEmpty:
        return Icons.fitness_center_outlined;
      default:
        return Icons.error_outline;
    }
  }

  static Widget _buildErrorDetails(BuildContext context, WorkoutProgramFailure failure) {
    final colors = context.colors;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: colors.info,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '해결 방법',
                  style: TextStyle(
                    color: colors.info,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getRecoverySuggestion(failure.type),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (failure.technicalMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              '기술적 세부사항: ${failure.technicalMessage}',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _getRecoverySuggestion(WorkoutProgramErrorType type) {
    switch (type) {
      case WorkoutProgramErrorType.networkError:
        return '네트워크 연결을 확인하고 다시 시도해주세요.';
      case WorkoutProgramErrorType.serverError:
        return '잠시 후 다시 시도해주세요.';
      case WorkoutProgramErrorType.repositoryNotInitialized:
        return '앱을 다시 시작하거나 로그인을 다시 해주세요.';
      case WorkoutProgramErrorType.dataParsingError:
        return '프로그램을 다시 불러오거나 앱을 재시작해주세요.';
      case WorkoutProgramErrorType.duplicate:
        return '기존 프로그램을 계속하거나 새로 시작할 수 있습니다.';
      case WorkoutProgramErrorType.permissionDenied:
        return '로그인 상태를 확인하고 다시 시도해주세요.';
      case WorkoutProgramErrorType.programNotFound:
        return '프로그램 목록을 새로고침하거나 다른 프로그램을 선택해주세요.';
      case WorkoutProgramErrorType.exerciseDataEmpty:
        return '프로그램 데이터를 다시 불러오거나 관리자에게 문의해주세요.';
      default:
        return '문제가 지속되면 고객센터에 문의해주세요.';
    }
  }

  static Widget _buildDialogAction(BuildContext context, WorkoutProgramErrorAction action) {
    final colors = context.colors;
    
    Color getButtonColor() {
      switch (action.type) {
        case WorkoutProgramErrorActionType.primary:
          return colors.primary;
        case WorkoutProgramErrorActionType.destructive:
          return colors.error;
        case WorkoutProgramErrorActionType.secondary:
          return colors.textSecondary;
        case WorkoutProgramErrorActionType.success:
          return colors.success;
      }
    }

    return action.type == WorkoutProgramErrorActionType.primary ||
           action.type == WorkoutProgramErrorActionType.success
        ? ElevatedButton(
            onPressed: action.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: getButtonColor(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(action.label),
          )
        : TextButton(
            onPressed: action.onPressed,
            child: Text(
              action.label,
              style: TextStyle(
                color: getButtonColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
  }
}

/// Workout program error dialog action configuration
class WorkoutProgramErrorAction {
  final String label;
  final VoidCallback onPressed;
  final WorkoutProgramErrorActionType type;

  const WorkoutProgramErrorAction({
    required this.label,
    required this.onPressed,
    this.type = WorkoutProgramErrorActionType.primary,
  });
}

/// Types of workout program error dialog actions
enum WorkoutProgramErrorActionType {
  primary,
  secondary,
  destructive,
  success,
}

/// Resolution options for duplicate programs
enum ResolutionOption {
  continueExisting,
  restartProgram,
  createNewInstance,
  cancel,
}