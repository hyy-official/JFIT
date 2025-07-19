import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'image_picker_widget.dart';
import 'video_picker_widget.dart';
import 'image_preview_widget.dart';
import 'video_preview_widget.dart';

/// Combined widget for picking both images and videos
class MediaPickerWidget extends StatefulWidget {
  final List<String> initialImagePaths;
  final String? initialVideoPath;
  final Function(List<String> imagePaths, String? videoPath)? onMediaChanged;
  final Function(List<String> imageUrls, String? videoUrl)? onMediaUploaded;
  final int maxImages;
  final bool allowImages;
  final bool allowVideo;
  final bool showPreview;
  final bool autoUpload;
  final String uploadBucket;
  final String? uploadFolder;
  final bool compressImages;
  final int imageQuality;
  final int maxImageSizeMB;
  final int maxVideoSizeMB;
  final Duration? maxVideoDuration;

  const MediaPickerWidget({
    super.key,
    this.initialImagePaths = const [],
    this.initialVideoPath,
    this.onMediaChanged,
    this.onMediaUploaded,
    this.maxImages = 5,
    this.allowImages = true,
    this.allowVideo = true,
    this.showPreview = true,
    this.autoUpload = false,
    this.uploadBucket = 'community',
    this.uploadFolder,
    this.compressImages = true,
    this.imageQuality = 85,
    this.maxImageSizeMB = 10,
    this.maxVideoSizeMB = 100,
    this.maxVideoDuration,
  });

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _imagePaths = [];
  String? _videoPath;
  List<String> _uploadedImageUrls = [];
  String? _uploadedVideoUrl;

  @override
  void initState() {
    super.initState();
    _imagePaths = List.from(widget.initialImagePaths);
    _videoPath = widget.initialVideoPath;
    
    // Initialize tab controller based on allowed media types
    final tabCount = (widget.allowImages ? 1 : 0) + (widget.allowVideo ? 1 : 0);
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // If only one media type is allowed, don't show tabs
    if (!widget.allowImages || !widget.allowVideo) {
      return _buildSingleMediaType();
    }

    return Column(
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [
              if (widget.allowImages)
                Tab(
                  icon: const Icon(LucideIcons.image),
                  text: '이미지 (${_imagePaths.length}/${widget.maxImages})',
                ),
              if (widget.allowVideo)
                Tab(
                  icon: const Icon(LucideIcons.video),
                  text: _videoPath != null ? '동영상 (1/1)' : '동영상 (0/1)',
                ),
            ],
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              if (widget.allowImages) _buildImagePicker(),
              if (widget.allowVideo) _buildVideoPicker(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleMediaType() {
    if (widget.allowImages && !widget.allowVideo) {
      return _buildImagePicker();
    } else if (widget.allowVideo && !widget.allowImages) {
      return _buildVideoPicker();
    }
    return const SizedBox.shrink();
  }

  Widget _buildImagePicker() {
    return ImagePickerWidget(
      initialImagePaths: _imagePaths,
      maxImages: widget.maxImages,
      allowMultiple: true,
      showPreview: widget.showPreview,
      autoUpload: widget.autoUpload,
      uploadBucket: widget.uploadBucket,
      uploadFolder: widget.uploadFolder,
      compressImages: widget.compressImages,
      imageQuality: widget.imageQuality,
      maxFileSizeMB: widget.maxImageSizeMB,
      onImagesChanged: (imagePaths) {
        setState(() {
          _imagePaths = imagePaths;
        });
        _notifyMediaChanged();
      },
      onImagesUploaded: (imageUrls) {
        setState(() {
          _uploadedImageUrls = imageUrls;
        });
        _notifyMediaUploaded();
      },
    );
  }

  Widget _buildVideoPicker() {
    return VideoPickerWidget(
      initialVideoPath: _videoPath,
      showPreview: widget.showPreview,
      autoUpload: widget.autoUpload,
      uploadBucket: widget.uploadBucket,
      uploadFolder: widget.uploadFolder,
      maxDuration: widget.maxVideoDuration,
      maxFileSizeMB: widget.maxVideoSizeMB,
      onVideoChanged: (videoPath) {
        setState(() {
          _videoPath = videoPath;
        });
        _notifyMediaChanged();
      },
      onVideoUploaded: (videoUrl) {
        setState(() {
          _uploadedVideoUrl = videoUrl;
        });
        _notifyMediaUploaded();
      },
    );
  }

  void _notifyMediaChanged() {
    widget.onMediaChanged?.call(_imagePaths, _videoPath);
  }

  void _notifyMediaUploaded() {
    widget.onMediaUploaded?.call(_uploadedImageUrls, _uploadedVideoUrl);
  }
}

/// Simple media picker button that opens a modal
class SimpleMediaPickerButton extends StatelessWidget {
  final Function(List<String> imagePaths, String? videoPath)? onMediaSelected;
  final Function(List<String> imageUrls, String? videoUrl)? onMediaUploaded;
  final int maxImages;
  final bool allowImages;
  final bool allowVideo;
  final bool autoUpload;
  final String buttonText;
  final IconData buttonIcon;

  const SimpleMediaPickerButton({
    super.key,
    this.onMediaSelected,
    this.onMediaUploaded,
    this.maxImages = 5,
    this.allowImages = true,
    this.allowVideo = true,
    this.autoUpload = false,
    this.buttonText = '미디어 선택',
    this.buttonIcon = LucideIcons.paperclip,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showMediaPickerDialog(context),
      icon: Icon(buttonIcon),
      label: Text(buttonText),
    );
  }

  void _showMediaPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Text(
                  '미디어 선택',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Media picker
            Expanded(
              child: MediaPickerWidget(
                maxImages: maxImages,
                allowImages: allowImages,
                allowVideo: allowVideo,
                autoUpload: autoUpload,
                onMediaChanged: onMediaSelected,
                onMediaUploaded: onMediaUploaded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying selected media (both images and video)
class MediaPreviewWidget extends StatelessWidget {
  final List<String> imagePaths;
  final String? videoPath;
  final List<String> imageUrls;
  final String? videoUrl;
  final Function(int index)? onRemoveImage;
  final VoidCallback? onRemoveVideo;
  final bool showRemoveButtons;
  final double itemHeight;

  const MediaPreviewWidget({
    super.key,
    this.imagePaths = const [],
    this.videoPath,
    this.imageUrls = const [],
    this.videoUrl,
    this.onRemoveImage,
    this.onRemoveVideo,
    this.showRemoveButtons = true,
    this.itemHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalMedia = imagePaths.isNotEmpty || videoPath != null;
    final hasUploadedMedia = imageUrls.isNotEmpty || videoUrl != null;
    
    if (!hasLocalMedia && !hasUploadedMedia) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Local media preview
        if (hasLocalMedia) ...[
          Text(
            '선택된 미디어',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Images
              if (imagePaths.isNotEmpty)
                Expanded(
                  child: ImagePreviewWidget(
                    imagePaths: imagePaths,
                    onRemove: onRemoveImage,
                    showRemoveButton: showRemoveButtons,
                    itemHeight: itemHeight,
                  ),
                ),
              
              // Video
              if (videoPath != null)
                Expanded(
                  child: VideoPreviewWidget(
                    videoPath: videoPath!,
                    onRemove: onRemoveVideo,
                    showRemoveButton: showRemoveButtons,
                    height: itemHeight,
                  ),
                ),
            ],
          ),
        ],
        
        // Uploaded media preview
        if (hasUploadedMedia) ...[
          if (hasLocalMedia) const SizedBox(height: 16),
          Text(
            '업로드된 미디어',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Uploaded images
              if (imageUrls.isNotEmpty)
                Expanded(
                  child: UploadedImagePreviewWidget(
                    imageUrls: imageUrls,
                    showRemoveButton: showRemoveButtons,
                    itemHeight: itemHeight,
                  ),
                ),
              
              // Uploaded video
              if (videoUrl != null)
                Expanded(
                  child: UploadedVideoPreviewWidget(
                    videoUrl: videoUrl!,
                    onRemove: onRemoveVideo,
                    showRemoveButton: showRemoveButtons,
                    height: itemHeight,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}