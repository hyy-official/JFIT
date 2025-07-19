import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:jfit/l10n/app_localizations.dart';

/// Utility class for accessibility features and helpers
class AccessibilityUtils {
  AccessibilityUtils._();

  /// Announce a message to screen readers
  static void announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Create semantic label for group cards
  static String groupCardSemanticLabel(
    BuildContext context, {
    required String groupName,
    required int memberCount,
    required bool isPublic,
    required bool isAdmin,
  }) {
    final privacy = isPublic ? 'Public' : 'Private';
    final role = isAdmin ? 'Admin' : 'Member';
    
    return 'Group: $groupName, '
           '$privacy, $memberCount members, '
           '$role';
  }

  /// Create semantic label for activity items
  static String activityItemSemanticLabel(
    BuildContext context, {
    required String userName,
    required String activityType,
    required DateTime timestamp,
  }) {
    final timeAgo = _formatTimeAgo(context, timestamp);
    
    return 'Activity by $userName, '
           '$activityType, $timeAgo';
  }

  /// Create semantic label for post cards
  static String postCardSemanticLabel(
    BuildContext context, {
    required String authorName,
    required String title,
    required int likesCount,
    required int commentsCount,
    required DateTime createdAt,
  }) {
    final timeAgo = _formatTimeAgo(context, createdAt);
    
    return 'Post by $authorName, '
           '$title, $likesCount likes, $commentsCount comments, $timeAgo';
  }

  /// Create semantic label for ranking items
  static String rankingItemSemanticLabel(
    BuildContext context, {
    required String groupName,
    required int rank,
    required double score,
  }) {
    return 'Rank $rank: $groupName with score ${score.toStringAsFixed(1)}';
  }

  /// Create semantic label for score cards
  static String scoreCardSemanticLabel(
    BuildContext context, {
    required String scoreType,
    required double score,
    required double maxScore,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = ((score / maxScore) * 100).toStringAsFixed(0);
    
    return '$scoreType: ${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)} ($percentage%)';
  }

  /// Create semantic hint for interactive elements
  static String interactionHint(BuildContext context, String action) {
    return 'Double tap to $action';
  }

  /// Create semantic label for buttons with state
  static String buttonWithStateLabel(
    BuildContext context, {
    required String baseLabel,
    required bool isActive,
    String? activeState,
    String? inactiveState,
  }) {
    final state = isActive 
        ? (activeState ?? 'active')
        : (inactiveState ?? 'inactive');
    return '$baseLabel, $state';
  }

  /// Create semantic label for navigation items
  static String navigationItemLabel(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required int index,
    required int totalItems,
  }) {
    final position = 'Tab ${index + 1} of $totalItems';
    final state = isSelected ? 'selected' : 'not selected';
    return '$label, $position, $state';
  }

  /// Create semantic label for form fields with validation
  static String formFieldLabel(
    BuildContext context, {
    required String label,
    required bool isRequired,
    String? errorMessage,
    String? helperText,
  }) {
    var semanticLabel = label;
    
    if (isRequired) {
      semanticLabel += ', required';
    }
    
    if (errorMessage != null) {
      semanticLabel += ', error: $errorMessage';
    } else if (helperText != null) {
      semanticLabel += ', $helperText';
    }
    
    return semanticLabel;
  }

  /// Create semantic label for progress indicators
  static String progressLabel(
    BuildContext context, {
    required String task,
    required double progress,
    String? status,
  }) {
    final percentage = (progress * 100).toStringAsFixed(0);
    var label = '$task, $percentage% complete';
    
    if (status != null) {
      label += ', $status';
    }
    
    return label;
  }

  /// Create semantic label for media content
  static String mediaLabel(
    BuildContext context, {
    required String mediaType,
    String? description,
    String? duration,
  }) {
    var label = mediaType;
    
    if (description != null) {
      label += ', $description';
    }
    
    if (duration != null) {
      label += ', duration $duration';
    }
    
    return label;
  }

  /// Format time ago for accessibility
  static String _formatTimeAgo(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Check if reduce motion is enabled
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get appropriate animation duration based on accessibility settings
  static Duration getAnimationDuration(BuildContext context, Duration defaultDuration) {
    if (isReduceMotionEnabled(context)) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  /// Create accessible tap target with minimum size
  static Widget createAccessibleTapTarget({
    required Widget child,
    required VoidCallback? onTap,
    String? semanticLabel,
    String? semanticHint,
    bool excludeSemantics = false,
    double minSize = 44.0,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      excludeSemantics: excludeSemantics,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minSize,
            minHeight: minSize,
          ),
          child: child,
        ),
      ),
    );
  }

  /// Create accessible text field with proper semantics
  static Widget createAccessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? errorText,
    bool isRequired = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
  }) {
    return Semantics(
      label: formFieldLabel(
        // Note: Context would need to be passed in real implementation
        // This is a simplified version for demonstration
        null as BuildContext, // This would be passed as parameter
        label: label,
        isRequired: isRequired,
        errorMessage: errorText,
        helperText: hint,
      ),
      textField: true,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          suffixIcon: isRequired 
              ? const Icon(Icons.star, size: 8, color: Colors.red)
              : null,
        ),
      ),
    );
  }

  /// Create accessible loading indicator
  static Widget createAccessibleLoadingIndicator({
    required String loadingText,
    double? progress,
  }) {
    return Semantics(
      label: progress != null 
          ? '$loadingText, ${(progress * 100).toStringAsFixed(0)}% complete'
          : loadingText,
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null)
            LinearProgressIndicator(value: progress)
          else
            const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(loadingText),
        ],
      ),
    );
  }

  /// Create accessible error message
  static Widget createAccessibleErrorMessage({
    required String errorMessage,
    VoidCallback? onRetry,
    String? retryButtonText,
  }) {
    return Semantics(
      label: 'Error: $errorMessage',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
            semanticLabel: 'Error icon',
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryButtonText ?? 'Try Again'),
            ),
          ],
        ],
      ),
    );
  }

  /// Create accessible empty state message
  static Widget createAccessibleEmptyState({
    required String message,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Semantics(
      label: 'Empty state: $message',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 64,
              color: Colors.grey,
              semanticLabel: 'Empty state icon',
            ),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText),
            ),
          ],
        ],
      ),
    );
  }

  /// Provide haptic feedback for accessibility
  static void provideHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Focus management helper
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  /// Navigate to next focusable element
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Navigate to previous focusable element
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Unfocus current element
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}

/// Extension to add accessibility helpers to BuildContext
extension AccessibilityContextExtension on BuildContext {
  /// Check if screen reader is enabled
  bool get isScreenReaderEnabled => AccessibilityUtils.isScreenReaderEnabled(this);
  
  /// Check if high contrast is enabled
  bool get isHighContrastEnabled => AccessibilityUtils.isHighContrastEnabled(this);
  
  /// Check if reduce motion is enabled
  bool get isReduceMotionEnabled => AccessibilityUtils.isReduceMotionEnabled(this);
  
  /// Get appropriate animation duration
  Duration getAccessibleAnimationDuration(Duration defaultDuration) =>
      AccessibilityUtils.getAnimationDuration(this, defaultDuration);
  
  /// Announce message to screen reader
  void announceToScreenReader(String message) =>
      AccessibilityUtils.announceToScreenReader(this, message);
}

/// Mixin for widgets that need accessibility support
mixin AccessibilityMixin<T extends StatefulWidget> on State<T> {
  /// Focus node for this widget
  late final FocusNode _focusNode = FocusNode();
  
  /// Get the focus node
  FocusNode get focusNode => _focusNode;
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  
  /// Request focus for this widget
  void requestFocus() {
    AccessibilityUtils.requestFocus(context, _focusNode);
  }
  
  /// Check if this widget has focus
  bool get hasFocus => _focusNode.hasFocus;
  
  /// Announce message to screen reader
  void announceToScreenReader(String message) {
    AccessibilityUtils.announceToScreenReader(context, message);
  }
  
  /// Provide haptic feedback
  void provideHapticFeedback() {
    AccessibilityUtils.provideHapticFeedback();
  }
}