import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/services/media_upload_service.dart';
import 'video_preview_widget.dart';

/// Widget for picking and managing videos with upload functionality
class VideoPickerWidget extends StatefulWidget {
  final String? initialVideoPath;
  final Function(String? videoPath)? onVideoChanged;
  final Function(String? uploadedUrl)? onVideoUploaded;
  final bool showPreview;
  final bool autoUpload;
  final String uploadBucket;
  final String? uploadFolder;
  final Duration? maxDuration;
  final int maxFileSizeMB;

  const VideoPickerWidget({
    super.key,
    this.initialVideoPath,
    this.onVideoChanged,
    this.onVideoUploaded,
    this.showPreview = true,
    this.autoUpload = false,
    this.uploadBucket = 'community',
    this.uploadFolder,
    this.maxDuration,
    this.maxFileSizeMB = 100, // 100MB default for videos
  });

  @override
  State<VideoPickerWidget> createState() => _VideoPickerWidgetState();
}

class _VideoPickerWidgetState extends State<VideoPickerWidget> {
  String? _videoPath;
  late MediaUploadService _mediaUploadService;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _videoPath = widget.initialVideoPath;
    _mediaUploadService = MediaUploadService();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video picker buttons
        _buildPickerButtons(theme),
        
        if (_uploadError != null) ...[
          const SizedBox(height: 8),
          _buildErrorMessage(theme),
        ],
        
        if (_isUploading) ...[
          const SizedBox(height: 8),
          _buildUploadProgress(theme),
        ],
        
        // Video preview
        if (widget.showPreview && _videoPath != null) ...[
          const SizedBox(height: 16),
          VideoPreviewWidget(
            videoPath: _videoPath!,
            onRemove: _removeVideo,
            showRemoveButton: true,
          ),
        ],
      ],
    );
  }

  Widget _buildPickerButtons(ThemeData theme) {
    return Row(
      children: [
        // Camera button
        if (_videoPath == null)
          _PickerButton(
            icon: LucideIcons.video,
            label: '동영상 촬영',
            onPressed: _isUploading ? null : () => _pickVideo(ImageSource.camera),
          ),
        
        if (_videoPath == null) const SizedBox(width: 12),
        
        // Gallery button
        if (_videoPath == null)
          _PickerButton(
            icon: LucideIcons.fileVideo,
            label: '갤러리',
            onPressed: _isUploading ? null : () => _pickVideo(ImageSource.gallery),
          ),
        
        const Spacer(),
        
        // Upload button (if not auto-upload)
        if (!widget.autoUpload && _videoPath != null)
          FilledButton.icon(
            onPressed: _isUploading ? null : _uploadVideo,
            icon: _isUploading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.upload),
            label: Text(_isUploading ? '업로드 중...' : '업로드'),
          ),
      ],
    );
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 16,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _uploadError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _uploadError = null),
            icon: Icon(
              LucideIcons.x,
              size: 16,
              color: theme.colorScheme.onErrorContainer,
            ),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.upload,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '업로드 중... ${(_uploadProgress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: _uploadProgress,
          backgroundColor: theme.colorScheme.surfaceVariant,
        ),
      ],
    );
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      setState(() {
        _uploadError = null;
      });

      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickVideo(
        source: source,
        maxDuration: widget.maxDuration,
      );

      if (pickedFile == null) return;

      // Validate file size
      final fileSize = await File(pickedFile.path).length();
      if (!_mediaUploadService.isFileSizeValid(fileSize, maxSizeMB: widget.maxFileSizeMB)) {
        setState(() {
          _uploadError = '파일 크기가 ${widget.maxFileSizeMB}MB를 초과합니다';
        });
        return;
      }

      setState(() {
        _videoPath = pickedFile.path;
      });

      widget.onVideoChanged?.call(_videoPath);

      // Auto-upload if enabled
      if (widget.autoUpload) {
        await _uploadVideo();
      }
    } catch (e) {
      setState(() {
        _uploadError = '동영상 선택 실패: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoPath == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadError = null;
    });

    try {
      final result = await _mediaUploadService.pickAndUploadVideo(
        source: ImageSource.gallery, // Not used since we already have the path
        bucket: widget.uploadBucket,
        folder: widget.uploadFolder,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      // Since we already have the video path, we'll use the uploadMediaFiles method instead
      final uploadResult = await _mediaUploadService.uploadMediaFiles(
        [_videoPath!],
        bucket: widget.uploadBucket,
        folder: widget.uploadFolder,
        compressImages: false, // Don't compress videos
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      uploadResult.fold(
        (failure) {
          setState(() {
            _uploadError = failure.message;
          });
        },
        (uploadedUrls) {
          final uploadedUrl = uploadedUrls.isNotEmpty ? uploadedUrls.first : null;
          widget.onVideoUploaded?.call(uploadedUrl);
          
          // Clear local path after successful upload
          setState(() {
            _videoPath = null;
          });
          widget.onVideoChanged?.call(_videoPath);
        },
      );
    } catch (e) {
      setState(() {
        _uploadError = '업로드 실패: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _removeVideo() {
    setState(() {
      _videoPath = null;
    });
    widget.onVideoChanged?.call(_videoPath);
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _PickerButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

/// Simple video picker button for basic use cases
class SimpleVideoPickerButton extends StatelessWidget {
  final Function(String? videoPath)? onVideoSelected;
  final Function(String? uploadedUrl)? onVideoUploaded;
  final bool autoUpload;
  final String buttonText;
  final IconData buttonIcon;
  final Duration? maxDuration;

  const SimpleVideoPickerButton({
    super.key,
    this.onVideoSelected,
    this.onVideoUploaded,
    this.autoUpload = false,
    this.buttonText = '동영상 선택',
    this.buttonIcon = LucideIcons.video,
    this.maxDuration,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showVideoPickerDialog(context),
      icon: Icon(buttonIcon),
      label: Text(buttonText),
    );
  }

  void _showVideoPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '동영상 선택',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            VideoPickerWidget(
              autoUpload: autoUpload,
              maxDuration: maxDuration,
              onVideoChanged: onVideoSelected,
              onVideoUploaded: onVideoUploaded,
            ),
          ],
        ),
      ),
    );
  }
}