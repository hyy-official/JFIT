import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/services/media_upload_service.dart';
import 'image_preview_widget.dart';

/// Widget for picking and managing images with upload functionality
class ImagePickerWidget extends StatefulWidget {
  final List<String> initialImagePaths;
  final Function(List<String> imagePaths)? onImagesChanged;
  final Function(List<String> uploadedUrls)? onImagesUploaded;
  final int maxImages;
  final bool allowMultiple;
  final bool showPreview;
  final bool autoUpload;
  final String uploadBucket;
  final String? uploadFolder;
  final bool compressImages;
  final int imageQuality;
  final int maxFileSizeMB;

  const ImagePickerWidget({
    super.key,
    this.initialImagePaths = const [],
    this.onImagesChanged,
    this.onImagesUploaded,
    this.maxImages = 5,
    this.allowMultiple = true,
    this.showPreview = true,
    this.autoUpload = false,
    this.uploadBucket = 'community',
    this.uploadFolder,
    this.compressImages = true,
    this.imageQuality = 85,
    this.maxFileSizeMB = 10,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  late List<String> _imagePaths;
  late MediaUploadService _mediaUploadService;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _imagePaths = List.from(widget.initialImagePaths);
    _mediaUploadService = MediaUploadService();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image picker buttons
        _buildPickerButtons(theme),
        
        if (_uploadError != null) ...[
          const SizedBox(height: 8),
          _buildErrorMessage(theme),
        ],
        
        if (_isUploading) ...[
          const SizedBox(height: 8),
          _buildUploadProgress(theme),
        ],
        
        // Image preview
        if (widget.showPreview && _imagePaths.isNotEmpty) ...[
          const SizedBox(height: 16),
          ImagePreviewWidget(
            imagePaths: _imagePaths,
            onRemove: _removeImage,
            onEdit: _editImage,
          ),
        ],
      ],
    );
  }

  Widget _buildPickerButtons(ThemeData theme) {
    final canAddMore = _imagePaths.length < widget.maxImages;
    
    return Row(
      children: [
        // Camera button
        if (canAddMore)
          _PickerButton(
            icon: LucideIcons.camera,
            label: '카메라',
            onPressed: _isUploading ? null : () => _pickImages(ImageSource.camera),
          ),
        
        if (canAddMore) const SizedBox(width: 12),
        
        // Gallery button
        if (canAddMore)
          _PickerButton(
            icon: LucideIcons.image,
            label: '갤러리',
            onPressed: _isUploading ? null : () => _pickImages(ImageSource.gallery),
          ),
        
        const Spacer(),
        
        // Upload button (if not auto-upload)
        if (!widget.autoUpload && _imagePaths.isNotEmpty)
          FilledButton.icon(
            onPressed: _isUploading ? null : _uploadImages,
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

  Future<void> _pickImages(ImageSource source) async {
    try {
      setState(() {
        _uploadError = null;
      });

      List<XFile> pickedFiles;
      final imagePicker = ImagePicker();

      if (widget.allowMultiple && source == ImageSource.gallery) {
        final remainingSlots = widget.maxImages - _imagePaths.length;
        pickedFiles = await imagePicker.pickMultipleMedia();
        
        // Limit to remaining slots
        if (pickedFiles.length > remainingSlots) {
          pickedFiles = pickedFiles.take(remainingSlots).toList();
        }
      } else {
        final pickedFile = await imagePicker.pickImage(source: source);
        pickedFiles = pickedFile != null ? [pickedFile] : [];
      }

      if (pickedFiles.isEmpty) return;

      // Validate file sizes
      final validFiles = <String>[];
      for (final file in pickedFiles) {
        final fileSize = await File(file.path).length();
        if (_mediaUploadService.isFileSizeValid(fileSize, maxSizeMB: widget.maxFileSizeMB)) {
          validFiles.add(file.path);
        } else {
          setState(() {
            _uploadError = '파일 크기가 ${widget.maxFileSizeMB}MB를 초과합니다: ${file.name}';
          });
        }
      }

      if (validFiles.isNotEmpty) {
        setState(() {
          _imagePaths.addAll(validFiles);
        });

        widget.onImagesChanged?.call(_imagePaths);

        // Auto-upload if enabled
        if (widget.autoUpload) {
          await _uploadImages();
        }
      }
    } catch (e) {
      setState(() {
        _uploadError = '이미지 선택 실패: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadImages() async {
    if (_imagePaths.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadError = null;
    });

    try {
      final result = await _mediaUploadService.uploadMediaFiles(
        _imagePaths,
        bucket: widget.uploadBucket,
        folder: widget.uploadFolder,
        compressImages: widget.compressImages,
        imageQuality: widget.imageQuality,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      result.fold(
        (failure) {
          setState(() {
            _uploadError = failure.message;
          });
        },
        (uploadedUrls) {
          widget.onImagesUploaded?.call(uploadedUrls);
          
          // Clear local paths after successful upload
          setState(() {
            _imagePaths.clear();
          });
          widget.onImagesChanged?.call(_imagePaths);
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

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
    widget.onImagesChanged?.call(_imagePaths);
  }

  void _editImage(int index) {
    // TODO: Implement image editing functionality
    // This could open an image editor or show editing options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이미지 편집 기능은 곧 추가될 예정입니다')),
    );
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

/// Simple image picker button for basic use cases
class SimpleImagePickerButton extends StatelessWidget {
  final Function(List<String> imagePaths)? onImagesSelected;
  final Function(List<String> uploadedUrls)? onImagesUploaded;
  final int maxImages;
  final bool allowMultiple;
  final bool autoUpload;
  final String buttonText;
  final IconData buttonIcon;

  const SimpleImagePickerButton({
    super.key,
    this.onImagesSelected,
    this.onImagesUploaded,
    this.maxImages = 5,
    this.allowMultiple = true,
    this.autoUpload = false,
    this.buttonText = '이미지 선택',
    this.buttonIcon = LucideIcons.image,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showImagePickerDialog(context),
      icon: Icon(buttonIcon),
      label: Text(buttonText),
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '이미지 선택',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ImagePickerWidget(
              maxImages: maxImages,
              allowMultiple: allowMultiple,
              autoUpload: autoUpload,
              onImagesChanged: onImagesSelected,
              onImagesUploaded: onImagesUploaded,
            ),
          ],
        ),
      ),
    );
  }
}