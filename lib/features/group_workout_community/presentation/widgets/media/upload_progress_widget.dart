import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Widget for displaying upload progress with detailed information
class UploadProgressWidget extends StatelessWidget {
  final double progress;
  final String? currentFileName;
  final int currentFileIndex;
  final int totalFiles;
  final int uploadedBytes;
  final int totalBytes;
  final String? error;
  final bool isCompleted;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const UploadProgressWidget({
    super.key,
    required this.progress,
    this.currentFileName,
    this.currentFileIndex = 0,
    this.totalFiles = 1,
    this.uploadedBytes = 0,
    this.totalBytes = 0,
    this.error,
    this.isCompleted = false,
    this.onCancel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (error != null) {
      return _buildErrorState(theme);
    }
    
    if (isCompleted) {
      return _buildCompletedState(theme);
    }
    
    return _buildProgressState(theme);
  }

  Widget _buildProgressState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                LucideIcons.upload,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '업로드 중...',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onCancel != null)
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(LucideIcons.x),
                  iconSize: 18,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          
          const SizedBox(height: 8),
          
          // Progress details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (totalFiles > 1)
                Text(
                  '$currentFileIndex / $totalFiles 파일',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          
          // Current file info
          if (currentFileName != null) ...[
            const SizedBox(height: 4),
            Text(
              currentFileName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Data transfer info
          if (totalBytes > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${_formatBytes(uploadedBytes)} / ${_formatBytes(totalBytes)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.checkCircle,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '업로드 완료',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (totalFiles > 1)
                  Text(
                    '$totalFiles개 파일이 성공적으로 업로드되었습니다',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                LucideIcons.alertCircle,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                '업로드 실패',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Error message
          Text(
            error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          
          // Retry button
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('다시 시도'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}

/// Compact upload progress indicator for smaller spaces
class CompactUploadProgressWidget extends StatelessWidget {
  final double progress;
  final bool isCompleted;
  final String? error;
  final VoidCallback? onCancel;

  const CompactUploadProgressWidget({
    super.key,
    required this.progress,
    this.isCompleted = false,
    this.error,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (error != null) {
      return _buildCompactError(theme);
    }
    
    if (isCompleted) {
      return _buildCompactCompleted(theme);
    }
    
    return _buildCompactProgress(theme);
  }

  Widget _buildCompactProgress(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onCancel != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCancel,
              child: Icon(
                LucideIcons.x,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactCompleted(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.checkCircle,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '완료',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactError(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 16,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            '실패',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Upload queue widget for managing multiple uploads
class UploadQueueWidget extends StatelessWidget {
  final List<UploadQueueItem> items;
  final Function(String id)? onCancel;
  final Function(String id)? onRetry;
  final VoidCallback? onClearCompleted;

  const UploadQueueWidget({
    super.key,
    required this.items,
    this.onCancel,
    this.onRetry,
    this.onClearCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '업로드 대기열',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                if (onClearCompleted != null && _hasCompletedItems())
                  TextButton(
                    onPressed: onClearCompleted,
                    child: const Text('완료된 항목 지우기'),
                  ),
              ],
            ),
          ),
          
          // Queue items
          ...items.map((item) => _buildQueueItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildQueueItem(BuildContext context, UploadQueueItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: UploadProgressWidget(
        progress: item.progress,
        currentFileName: item.fileName,
        error: item.error,
        isCompleted: item.isCompleted,
        onCancel: () => onCancel?.call(item.id),
        onRetry: () => onRetry?.call(item.id),
      ),
    );
  }

  bool _hasCompletedItems() {
    return items.any((item) => item.isCompleted);
  }
}

/// Data class for upload queue items
class UploadQueueItem {
  final String id;
  final String fileName;
  final double progress;
  final String? error;
  final bool isCompleted;

  const UploadQueueItem({
    required this.id,
    required this.fileName,
    required this.progress,
    this.error,
    this.isCompleted = false,
  });

  UploadQueueItem copyWith({
    String? id,
    String? fileName,
    double? progress,
    String? error,
    bool? isCompleted,
  }) {
    return UploadQueueItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}