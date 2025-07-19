import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Widget for previewing selected videos before upload
class VideoPreviewWidget extends StatefulWidget {
  final String videoPath;
  final VoidCallback? onRemove;
  final VoidCallback? onPlay;
  final bool showRemoveButton;
  final bool showPlayButton;
  final double height;
  final EdgeInsets padding;

  const VideoPreviewWidget({
    super.key,
    required this.videoPath,
    this.onRemove,
    this.onPlay,
    this.showRemoveButton = true,
    this.showPlayButton = true,
    this.height = 200,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  bool _isGeneratingThumbnail = false;
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: widget.height + widget.padding.vertical,
      padding: widget.padding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            // Video thumbnail or placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildVideoThumbnail(theme),
            ),
            
            // Overlay with gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            
            // Play button
            if (widget.showPlayButton)
              Positioned.fill(
                child: Center(
                  child: _ActionButton(
                    icon: LucideIcons.play,
                    onPressed: widget.onPlay ?? _playVideo,
                    backgroundColor: Colors.black.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    size: 48,
                    iconSize: 24,
                  ),
                ),
              ),
            
            // Remove button
            if (widget.showRemoveButton && widget.onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: _ActionButton(
                  icon: LucideIcons.x,
                  onPressed: widget.onRemove!,
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
            
            // Video info
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: _buildVideoInfo(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(ThemeData theme) {
    if (_isGeneratingThumbnail) {
      return Container(
        width: double.infinity,
        height: widget.height,
        color: theme.colorScheme.surfaceVariant,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                '썸네일 생성 중...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_thumbnailPath != null) {
      return Image.file(
        File(_thumbnailPath!),
        width: double.infinity,
        height: widget.height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildVideoPlaceholder(theme);
        },
      );
    }

    return _buildVideoPlaceholder(theme);
  }

  Widget _buildVideoPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: widget.height,
      color: theme.colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.video,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            '동영상',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo(ThemeData theme) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getVideoInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final info = snapshot.data!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                info['duration'] ?? '00:00',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                info['size'] ?? '',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generateThumbnail() async {
    setState(() {
      _isGeneratingThumbnail = true;
    });

    try {
      // For now, we'll skip thumbnail generation as it requires additional packages
      // In a real implementation, you would use packages like video_thumbnail
      // to generate thumbnails from video files
      
      // Simulate thumbnail generation delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isGeneratingThumbnail = false;
        // _thumbnailPath would be set here in real implementation
      });
    } catch (e) {
      setState(() {
        _isGeneratingThumbnail = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getVideoInfo() async {
    try {
      final file = File(widget.videoPath);
      final fileSize = await file.length();
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      
      return {
        'duration': '00:00', // Would be calculated from video metadata
        'size': '${fileSizeMB}MB',
      };
    } catch (e) {
      return {
        'duration': '00:00',
        'size': '0MB',
      };
    }
  }

  void _playVideo() {
    // For now, show a message that video playback is not implemented
    // In a real implementation, you would use video_player package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('동영상 재생 기능은 곧 추가될 예정입니다')),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double size;
  final double iconSize;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.size = 32,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying uploaded videos with URLs
class UploadedVideoPreviewWidget extends StatelessWidget {
  final String videoUrl;
  final VoidCallback? onRemove;
  final VoidCallback? onPlay;
  final bool showRemoveButton;
  final bool showPlayButton;
  final double height;
  final EdgeInsets padding;

  const UploadedVideoPreviewWidget({
    super.key,
    required this.videoUrl,
    this.onRemove,
    this.onPlay,
    this.showRemoveButton = true,
    this.showPlayButton = true,
    this.height = 200,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: height + padding.vertical,
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            // Video placeholder (since we can't easily show video thumbnails from URLs)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: height,
                color: theme.colorScheme.surfaceVariant,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.video,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '업로드된 동영상',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Overlay with gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            
            // Play button
            if (showPlayButton)
              Positioned.fill(
                child: Center(
                  child: _ActionButton(
                    icon: LucideIcons.play,
                    onPressed: onPlay ?? () => _playVideo(context),
                    backgroundColor: Colors.black.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    size: 48,
                    iconSize: 24,
                  ),
                ),
              ),
            
            // Remove button
            if (showRemoveButton && onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: _ActionButton(
                  icon: LucideIcons.x,
                  onPressed: onRemove!,
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _playVideo(BuildContext context) {
    // For now, show a message that video playback is not implemented
    // In a real implementation, you would use video_player package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('동영상 재생 기능은 곧 추가될 예정입니다')),
    );
  }
}