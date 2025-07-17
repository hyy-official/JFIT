import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../theme/theme_system.dart';
import '../error/bloc_errors.dart';

/// Enhanced error feedback widgets for better user experience
class EnhancedErrorFeedback {
  /// Show enhanced SnackBar with Korean error messages and action options
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
    bool isRetryable = false,
  }) {
    final colors = context.colors;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: colors.onError,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.onError,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: (actionLabel != null && onActionPressed != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: colors.onError,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }

  /// Show success SnackBar with Korean messages
  static void showSuccessSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = context.colors;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: colors.onSuccess,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.onSuccess,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show info SnackBar with Korean messages
  static void showInfoSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = context.colors;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.info,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show enhanced error dialog with action options
  static Future<T?> showErrorDialog<T>(
    BuildContext context, {
    required String title,
    required String message,
    String? recoverySuggestion,
    List<ErrorDialogAction> actions = const [],
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
              Icons.error_outline,
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
            if (recoverySuggestion != null) ...[
              const SizedBox(height: 16),
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
                child: Row(
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
                        recoverySuggestion,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

  /// Show loading dialog during error recovery attempts
  static Future<T?> showLoadingDialog<T>(
    BuildContext context, {
    required String message,
    bool barrierDismissible = false,
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
  }

  /// Build dialog action button
  static Widget _buildDialogAction(BuildContext context, ErrorDialogAction action) {
    final colors = context.colors;
    
    Color getButtonColor() {
      switch (action.type) {
        case ErrorDialogActionType.primary:
          return colors.primary;
        case ErrorDialogActionType.destructive:
          return colors.error;
        case ErrorDialogActionType.secondary:
          return colors.textSecondary;
      }
    }

    return TextButton(
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

/// Error dialog action configuration
class ErrorDialogAction {
  final String label;
  final VoidCallback onPressed;
  final ErrorDialogActionType type;

  const ErrorDialogAction({
    required this.label,
    required this.onPressed,
    this.type = ErrorDialogActionType.primary,
  });
}

/// Types of error dialog actions
enum ErrorDialogActionType {
  primary,
  secondary,
  destructive,
}

/// Enhanced error state widget for BLoC error states
class ErrorStateWidget extends StatelessWidget {
  final BlocError error;
  final VoidCallback? onRetry;
  final String? customMessage;
  final String? customRecoverySuggestion;
  final bool showRetryButton;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
    this.customRecoverySuggestion,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final userMessage = customMessage ?? BlocErrorHandler.getUserFriendlyMessage(error);
    final recoverySuggestion = customRecoverySuggestion ?? _getRecoverySuggestion();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(),
              size: 64,
              color: colors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              userMessage,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (recoverySuggestion != null) ...[
              const SizedBox(height: 8),
              Text(
                recoverySuggestion,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(_getRetryButtonText()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.code) {
      case BlocErrorCodes.networkError:
      case BlocErrorCodes.connectionTimeout:
        return Icons.wifi_off;
      case BlocErrorCodes.serverError:
        return Icons.cloud_off;
      case BlocErrorCodes.repositoryNotInitialized:
        return Icons.settings_backup_restore;
      case BlocErrorCodes.dataParsingError:
      case BlocErrorCodes.exerciseDataEmpty:
        return Icons.data_usage;
      case BlocErrorCodes.permissionDenied:
      case BlocErrorCodes.authenticationRequired:
        return Icons.lock_outline;
      case BlocErrorCodes.programDuplicate:
        return Icons.content_copy;
      default:
        return Icons.error_outline;
    }
  }

  String? _getRecoverySuggestion() {
    switch (error.code) {
      case BlocErrorCodes.networkError:
        return '네트워크 연결을 확인하고 다시 시도해주세요.';
      case BlocErrorCodes.serverError:
        return '잠시 후 다시 시도해주세요.';
      case BlocErrorCodes.repositoryNotInitialized:
        return '앱을 다시 시작하거나 로그인을 다시 해주세요.';
      case BlocErrorCodes.dataParsingError:
        return '프로그램을 다시 불러오거나 앱을 재시작해주세요.';
      case BlocErrorCodes.programDuplicate:
        return '기존 프로그램을 계속하거나 새로 시작할 수 있습니다.';
      case BlocErrorCodes.permissionDenied:
        return '로그인 상태를 확인하고 다시 시도해주세요.';
      case BlocErrorCodes.validationError:
        return '입력한 정보를 확인하고 다시 시도해주세요.';
      default:
        return '문제가 지속되면 고객센터에 문의해주세요.';
    }
  }

  String _getRetryButtonText() {
    switch (error.code) {
      case BlocErrorCodes.networkError:
      case BlocErrorCodes.connectionTimeout:
        return '다시 연결';
      case BlocErrorCodes.serverError:
        return '새로고침';
      case BlocErrorCodes.repositoryNotInitialized:
        return '다시 시도';
      case BlocErrorCodes.dataParsingError:
        return '새로고침';
      default:
        return '다시 시도';
    }
  }
}

/// Loading state widget with Korean messages
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colors.primary,
            strokeWidth: 3,
          ),
          if (showMessage) ...[
            const SizedBox(height: 16),
            Text(
              message ?? '불러오는 중...',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}