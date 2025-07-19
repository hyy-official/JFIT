import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/media/media_picker_widget.dart';
import '../widgets/media/image_picker_widget.dart';
import '../widgets/media/video_picker_widget.dart';
import '../widgets/media/upload_progress_widget.dart';

/// Demo page showing media upload functionality
class MediaUploadDemoPage extends StatefulWidget {
  const MediaUploadDemoPage({super.key});

  @override
  State<MediaUploadDemoPage> createState() => _MediaUploadDemoPageState();
}

class _MediaUploadDemoPageState extends State<MediaUploadDemoPage> {
  List<String> _selectedImagePaths = [];
  String? _selectedVideoPath;
  List<String> _uploadedImageUrls = [];
  String? _uploadedVideoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('미디어 업로드 데모'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Combined media picker
            _buildSection(
              title: '통합 미디어 선택기',
              description: '이미지와 동영상을 함께 선택할 수 있습니다',
              child: MediaPickerWidget(
                maxImages: 3,
                allowImages: true,
                allowVideo: true,
                showPreview: true,
                autoUpload: false,
                onMediaChanged: (imagePaths, videoPath) {
                  setState(() {
                    _selectedImagePaths = imagePaths;
                    _selectedVideoPath = videoPath;
                  });
                },
                onMediaUploaded: (imageUrls, videoUrl) {
                  setState(() {
                    _uploadedImageUrls = imageUrls;
                    _uploadedVideoUrl = videoUrl;
                  });
                  _showUploadSuccessSnackBar();
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Image picker only
            _buildSection(
              title: '이미지 선택기',
              description: '이미지만 선택할 수 있습니다',
              child: ImagePickerWidget(
                maxImages: 5,
                allowMultiple: true,
                showPreview: true,
                autoUpload: false,
                compressImages: true,
                imageQuality: 85,
                onImagesChanged: (imagePaths) {
                  debugPrint('Images changed: ${imagePaths.length}');
                },
                onImagesUploaded: (imageUrls) {
                  debugPrint('Images uploaded: ${imageUrls.length}');
                  _showUploadSuccessSnackBar();
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Video picker only
            _buildSection(
              title: '동영상 선택기',
              description: '동영상만 선택할 수 있습니다',
              child: VideoPickerWidget(
                showPreview: true,
                autoUpload: false,
                maxDuration: const Duration(minutes: 5),
                maxFileSizeMB: 100,
                onVideoChanged: (videoPath) {
                  debugPrint('Video changed: $videoPath');
                },
                onVideoUploaded: (videoUrl) {
                  debugPrint('Video uploaded: $videoUrl');
                  _showUploadSuccessSnackBar();
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Simple buttons
            _buildSection(
              title: '간단한 버튼들',
              description: '모달로 열리는 간단한 선택기들',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SimpleMediaPickerButton(
                    buttonText: '미디어 선택',
                    buttonIcon: LucideIcons.paperclip,
                    maxImages: 3,
                    allowImages: true,
                    allowVideo: true,
                    onMediaSelected: (imagePaths, videoPath) {
                      debugPrint('Media selected: ${imagePaths.length} images, video: $videoPath');
                    },
                  ),
                  SimpleImagePickerButton(
                    buttonText: '이미지 선택',
                    buttonIcon: LucideIcons.image,
                    maxImages: 5,
                    onImagesSelected: (imagePaths) {
                      debugPrint('Images selected: ${imagePaths.length}');
                    },
                  ),
                  SimpleVideoPickerButton(
                    buttonText: '동영상 선택',
                    buttonIcon: LucideIcons.video,
                    maxDuration: const Duration(minutes: 3),
                    onVideoSelected: (videoPath) {
                      debugPrint('Video selected: $videoPath');
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Upload progress examples
            _buildSection(
              title: '업로드 진행률 표시',
              description: '다양한 업로드 상태를 보여줍니다',
              child: Column(
                children: [
                  // Progress state
                  UploadProgressWidget(
                    progress: 0.65,
                    currentFileName: 'example_image.jpg',
                    currentFileIndex: 2,
                    totalFiles: 3,
                    uploadedBytes: 1024 * 650,
                    totalBytes: 1024 * 1000,
                    onCancel: () => debugPrint('Upload cancelled'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Completed state
                  const UploadProgressWidget(
                    progress: 1.0,
                    isCompleted: true,
                    totalFiles: 3,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Error state
                  UploadProgressWidget(
                    progress: 0.3,
                    error: '네트워크 연결이 불안정합니다',
                    onRetry: () => debugPrint('Retry upload'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Compact progress indicators
                  Row(
                    children: [
                      const CompactUploadProgressWidget(
                        progress: 0.45,
                      ),
                      const SizedBox(width: 12),
                      const CompactUploadProgressWidget(
                        progress: 1.0,
                        isCompleted: true,
                      ),
                      const SizedBox(width: 12),
                      CompactUploadProgressWidget(
                        progress: 0.2,
                        error: '실패',
                        onCancel: () => debugPrint('Cancel compact upload'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Upload queue example
            _buildSection(
              title: '업로드 대기열',
              description: '여러 파일의 업로드 상태를 관리합니다',
              child: UploadQueueWidget(
                items: [
                  const UploadQueueItem(
                    id: '1',
                    fileName: 'workout_video.mp4',
                    progress: 0.8,
                  ),
                  const UploadQueueItem(
                    id: '2',
                    fileName: 'progress_photo.jpg',
                    progress: 1.0,
                    isCompleted: true,
                  ),
                  const UploadQueueItem(
                    id: '3',
                    fileName: 'routine_screenshot.png',
                    progress: 0.3,
                    error: '파일 크기가 너무 큽니다',
                  ),
                ],
                onCancel: (id) => debugPrint('Cancel upload: $id'),
                onRetry: (id) => debugPrint('Retry upload: $id'),
                onClearCompleted: () => debugPrint('Clear completed uploads'),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Selected media summary
            if (_selectedImagePaths.isNotEmpty || _selectedVideoPath != null) ...[
              _buildSection(
                title: '선택된 미디어',
                description: '현재 선택된 미디어 파일들',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedImagePaths.isNotEmpty)
                      Text('이미지: ${_selectedImagePaths.length}개'),
                    if (_selectedVideoPath != null)
                      const Text('동영상: 1개'),
                  ],
                ),
              ),
            ],
            
            // Uploaded media summary
            if (_uploadedImageUrls.isNotEmpty || _uploadedVideoUrl != null) ...[
              const SizedBox(height: 16),
              _buildSection(
                title: '업로드된 미디어',
                description: '성공적으로 업로드된 미디어 파일들',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_uploadedImageUrls.isNotEmpty)
                      Text('업로드된 이미지: ${_uploadedImageUrls.length}개'),
                    if (_uploadedVideoUrl != null)
                      const Text('업로드된 동영상: 1개'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  void _showUploadSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('미디어 업로드가 완료되었습니다!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}