import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/utils/accessibility_utils.dart';

/// Utility class for user experience optimizations
class UXOptimizationUtils {
  UXOptimizationUtils._();

  /// Show optimized snackbar with accessibility support
  static void showOptimizedSnackBar(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool isError = false,
    bool isSuccess = false,
  }) {
    // Determine colors based on message type
    Color? bgColor = backgroundColor;
    Color? txtColor = textColor;
    IconData? messageIcon = icon;

    if (isError) {
      bgColor ??= Colors.red.shade600;
      txtColor ??= Colors.white;
      messageIcon ??= Icons.error_outline;
    } else if (isSuccess) {
      bgColor ??= Colors.green.shade600;
      txtColor ??= Colors.white;
      messageIcon ??= Icons.check_circle_outline;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (messageIcon != null) ...[
            Icon(
              messageIcon,
              color: txtColor,
              semanticLabel: isError ? 'Error' : isSuccess ? 'Success' : null,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: txtColor),
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Announce to screen reader
    if (context.isScreenReaderEnabled) {
      final announcement = isError 
          ? 'Error: $message'
          : isSuccess 
              ? 'Success: $message'
              : message;
      context.announceToScreenReader(announcement);
    }

    // Provide haptic feedback
    if (isError) {
      HapticFeedback.vibrate();
    } else if (isSuccess) {
      HapticFeedback.lightImpact();
    }
  }

  /// Show optimized loading dialog
  static void showOptimizedLoadingDialog(
    BuildContext context, {
    required String message,
    bool barrierDismissible = false,
    double? progress,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: AlertDialog(
          content: AccessibilityUtils.createAccessibleLoadingIndicator(
            loadingText: message,
            progress: progress,
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Show optimized confirmation dialog
  static Future<bool?> showOptimizedConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDestructive ? Colors.red : null,
                semanticLabel: isDestructive ? 'Warning' : null,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red : null,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmText ?? l10n.confirm),
          ),
        ],
      ),
    );
  }

  /// Show optimized error dialog
  static void showOptimizedErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              semanticLabel: 'Error',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(l10n.tryAgain),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText ?? l10n.close),
          ),
        ],
      ),
    );

    // Announce error to screen reader
    if (context.isScreenReaderEnabled) {
      context.announceToScreenReader('Error: $title. $message');
    }

    // Provide haptic feedback
    HapticFeedback.vibrate();
  }

  /// Show optimized bottom sheet
  static Future<T?> showOptimizedBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            if (title != null) ...[
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            // Content
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  /// Create optimized pull-to-refresh
  static Widget createOptimizedRefreshIndicator({
    required Widget child,
    required Future<void> Function() onRefresh,
    String? semanticLabel,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Semantics(
        label: semanticLabel ?? 'Pull to refresh',
        child: child,
      ),
    );
  }

  /// Create optimized infinite scroll
  static Widget createOptimizedInfiniteScroll({
    required Widget child,
    required VoidCallback onLoadMore,
    required bool hasMore,
    required bool isLoading,
    String? loadingText,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!isLoading && 
            hasMore && 
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore();
        }
        return false;
      },
      child: Column(
        children: [
          Expanded(child: child),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: AccessibilityUtils.createAccessibleLoadingIndicator(
                loadingText: loadingText ?? 'Loading more...',
              ),
            ),
        ],
      ),
    );
  }

  /// Create optimized search field
  static Widget createOptimizedSearchField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    VoidCallback? onClear,
    VoidCallback? onSubmitted,
    bool autofocus = false,
    List<String>? suggestions,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                  onClear?.call();
                },
                tooltip: 'Clear search',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  /// Create optimized filter chips
  static Widget createOptimizedFilterChips<T>({
    required List<T> options,
    required Set<T> selectedOptions,
    required ValueChanged<Set<T>> onSelectionChanged,
    required String Function(T) labelBuilder,
    bool multiSelect = true,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? 'Filter options',
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: options.map((option) {
          final isSelected = selectedOptions.contains(option);
          return FilterChip(
            label: Text(labelBuilder(option)),
            selected: isSelected,
            onSelected: (selected) {
              final newSelection = Set<T>.from(selectedOptions);
              if (multiSelect) {
                if (selected) {
                  newSelection.add(option);
                } else {
                  newSelection.remove(option);
                }
              } else {
                newSelection.clear();
                if (selected) {
                  newSelection.add(option);
                }
              }
              onSelectionChanged(newSelection);
            },
          );
        }).cast<Widget>().toList(),
      ),
    );
  }

  /// Create optimized empty state
  static Widget createOptimizedEmptyState({
    required String title,
    required String message,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
    bool showAnimation = true,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AnimatedContainer(
                duration: showAnimation ? const Duration(milliseconds: 300) : Duration.zero,
                child: Icon(
                  icon,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Create optimized card with consistent styling
  static Widget createOptimizedCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
    Color? backgroundColor,
    String? semanticLabel,
    bool showBorder = false,
  }) {
    Widget card = Card(
      elevation: elevation ?? 2,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: showBorder 
            ? BorderSide(color: Colors.grey.shade300)
            : BorderSide.none,
      ),
      margin: margin ?? const EdgeInsets.all(8),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }

    return card;
  }

  /// Create optimized list tile with consistent styling
  static Widget createOptimizedListTile({
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isThreeLine = false,
    String? semanticLabel,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        isThreeLine: isThreeLine,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Create optimized floating action button
  static Widget createOptimizedFAB({
    required VoidCallback onPressed,
    required Widget child,
    String? tooltip,
    String? semanticLabel,
    bool mini = false,
    Color? backgroundColor,
  }) {
    return Semantics(
      label: semanticLabel ?? tooltip,
      button: true,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        mini: mini,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }

  /// Create optimized tab bar
  static Widget createOptimizedTabBar({
    required List<String> tabs,
    required TabController controller,
    bool isScrollable = false,
    Color? indicatorColor,
    Color? labelColor,
    Color? unselectedLabelColor,
  }) {
    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      indicatorColor: indicatorColor,
      labelColor: labelColor,
      unselectedLabelColor: unselectedLabelColor,
      tabs: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        return Semantics(
          label: AccessibilityUtils.navigationItemLabel(
            null as BuildContext, // Would be passed in real implementation
            label: label,
            isSelected: controller.index == index,
            index: index,
            totalItems: tabs.length,
          ),
          child: Tab(text: label),
        );
      }).toList(),
    );
  }

  /// Provide consistent haptic feedback
  static void provideHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Copy text to clipboard with feedback
  static Future<void> copyToClipboard(
    BuildContext context, {
    required String text,
    String? successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    
    final l10n = AppLocalizations.of(context)!;
    showOptimizedSnackBar(
      context,
      message: successMessage ?? 'Copied to clipboard',
      isSuccess: true,
      duration: const Duration(seconds: 2),
    );
  }

  /// Share content with platform sharing
  static Future<void> shareContent(
    BuildContext context, {
    required String text,
    String? subject,
  }) async {
    // This would use the share_plus package in a real implementation
    // For now, we'll copy to clipboard as fallback
    await copyToClipboard(
      context,
      text: text,
      successMessage: 'Content copied to clipboard for sharing',
    );
  }

  /// Create optimized progress indicator
  static Widget createOptimizedProgressIndicator({
    double? value,
    String? label,
    Color? color,
    Color? backgroundColor,
    double height = 8,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: backgroundColor ?? Colors.grey.shade200,
            minHeight: height,
            semanticsLabel: label,
            semanticsValue: value != null 
                ? '${(value * 100).toStringAsFixed(0)}%'
                : null,
          ),
        ),
      ],
    );
  }
}

/// Extension to add UX optimization helpers to BuildContext
extension UXOptimizationContextExtension on BuildContext {
  /// Show success snackbar
  void showSuccessSnackBar(String message, {SnackBarAction? action}) {
    UXOptimizationUtils.showOptimizedSnackBar(
      this,
      message: message,
      isSuccess: true,
      action: action,
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message, {SnackBarAction? action}) {
    UXOptimizationUtils.showOptimizedSnackBar(
      this,
      message: message,
      isError: true,
      action: action,
    );
  }

  /// Show loading dialog
  void showLoadingDialog(String message, {double? progress}) {
    UXOptimizationUtils.showOptimizedLoadingDialog(
      this,
      message: message,
      progress: progress,
    );
  }

  /// Hide loading dialog
  void hideLoadingDialog() {
    UXOptimizationUtils.hideLoadingDialog(this);
  }

  /// Show confirmation dialog
  Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    IconData? icon,
  }) {
    return UXOptimizationUtils.showOptimizedConfirmationDialog(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
      icon: icon,
    );
  }

  /// Show error dialog
  void showErrorDialog({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onRetry,
  }) {
    UXOptimizationUtils.showOptimizedErrorDialog(
      this,
      title: title,
      message: message,
      buttonText: buttonText,
      onRetry: onRetry,
    );
  }

  /// Copy to clipboard
  Future<void> copyToClipboard(String text, {String? successMessage}) {
    return UXOptimizationUtils.copyToClipboard(
      this,
      text: text,
      successMessage: successMessage,
    );
  }

  /// Share content
  Future<void> shareContent(String text, {String? subject}) {
    return UXOptimizationUtils.shareContent(
      this,
      text: text,
      subject: subject,
    );
  }
}