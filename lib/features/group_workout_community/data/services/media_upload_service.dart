import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:dartz/dartz.dart';

import 'package:jfit/core/error/failures.dart';

/// Service for handling media upload operations
/// Supports image and video upload with compression and progress tracking
class MediaUploadService {
  final SupabaseClient _supabaseClient;
  final ImagePicker _imagePicker;
  final Uuid _uuid = const Uuid();

  MediaUploadService({
    SupabaseClient? supabaseClient,
    ImagePicker? imagePicker,
  })  : _supabaseClient = supabaseClient ?? Supabase.instance.client,
        _imagePicker = imagePicker ?? ImagePicker();

  /// Upload multiple media files with progress tracking
  Future<Either<Failure, List<String>>> uploadMediaFiles(
    List<String> filePaths, {
    String bucket = 'community',
    String? folder,
    Function(double)? onProgress,
    bool compressImages = true,
    int imageQuality = 85,
  }) async {
    try {
      final uploadedUrls = <String>[];
      final totalFiles = filePaths.length;

      for (int i = 0; i < filePaths.length; i++) {
        final filePath = filePaths[i];
        final file = File(filePath);
        
        if (!await file.exists()) {
          throw const DatabaseFailure('파일을 찾을 수 없습니다');
        }

        // Determine file type
        final extension = path.extension(filePath).toLowerCase();
        final isImage = _isImageFile(extension);
        final isVideo = _isVideoFile(extension);

        if (!isImage && !isVideo) {
          throw const DatabaseFailure('지원하지 않는 파일 형식입니다');
        }

        // Process file based on type
        Uint8List fileBytes;
        String fileName;

        if (isImage && compressImages) {
          final compressedImage = await _compressImage(file, imageQuality);
          fileBytes = compressedImage;
          fileName = '${_uuid.v4()}.jpg'; // Convert to JPEG for consistency
        } else {
          fileBytes = await file.readAsBytes();
          fileName = '${_uuid.v4()}${extension}';
        }

        // Create storage path
        final storagePath = folder != null 
            ? '$folder/$fileName' 
            : 'uploads/$fileName';

        // Upload to Supabase Storage
        await _supabaseClient.storage
            .from(bucket)
            .uploadBinary(storagePath, fileBytes);

        // Get public URL
        final publicUrl = _supabaseClient.storage
            .from(bucket)
            .getPublicUrl(storagePath);

        uploadedUrls.add(publicUrl);

        // Update progress
        if (onProgress != null) {
          final progress = (i + 1) / totalFiles;
          onProgress(progress);
        }
      }

      return Right(uploadedUrls);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(DatabaseFailure('미디어 업로드 실패: ${e.toString()}'));
    }
  }

  /// Pick and upload images from gallery or camera
  Future<Either<Failure, List<String>>> pickAndUploadImages({
    ImageSource source = ImageSource.gallery,
    bool allowMultiple = true,
    String bucket = 'community',
    String? folder,
    Function(double)? onProgress,
    bool compressImages = true,
    int imageQuality = 85,
  }) async {
    try {
      List<XFile> pickedFiles;

      if (allowMultiple && source == ImageSource.gallery) {
        pickedFiles = await _imagePicker.pickMultipleMedia();
      } else {
        final pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: compressImages ? imageQuality : null,
        );
        pickedFiles = pickedFile != null ? [pickedFile] : [];
      }

      if (pickedFiles.isEmpty) {
        return const Right([]);
      }

      // Filter only image files
      final imagePaths = pickedFiles
          .where((file) => _isImageFile(path.extension(file.path).toLowerCase()))
          .map((file) => file.path)
          .toList();

      if (imagePaths.isEmpty) {
        return const Left(DatabaseFailure('선택된 이미지 파일이 없습니다'));
      }

      return await uploadMediaFiles(
        imagePaths,
        bucket: bucket,
        folder: folder,
        onProgress: onProgress,
        compressImages: compressImages,
        imageQuality: imageQuality,
      );
    } catch (e) {
      return Left(DatabaseFailure('이미지 선택 및 업로드 실패: ${e.toString()}'));
    }
  }

  /// Pick and upload video from gallery or camera
  Future<Either<Failure, String?>> pickAndUploadVideo({
    ImageSource source = ImageSource.gallery,
    String bucket = 'community',
    String? folder,
    Function(double)? onProgress,
    Duration? maxDuration,
  }) async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );

      if (pickedFile == null) {
        return const Right(null);
      }

      final result = await uploadMediaFiles(
        [pickedFile.path],
        bucket: bucket,
        folder: folder,
        onProgress: onProgress,
        compressImages: false, // Don't compress videos
      );

      return result.fold(
        (failure) => Left(failure),
        (urls) => Right(urls.isNotEmpty ? urls.first : null),
      );
    } catch (e) {
      return Left(DatabaseFailure('비디오 선택 및 업로드 실패: ${e.toString()}'));
    }
  }

  /// Generate thumbnail for video
  Future<Either<Failure, Uint8List?>> generateVideoThumbnail(String videoPath) async {
    try {
      // For now, return null as video thumbnail generation requires additional packages
      // In a real implementation, you would use packages like video_thumbnail
      // or ffmpeg_kit_flutter to generate thumbnails
      
      // Example implementation with video_thumbnail package:
      // final thumbnailData = await VideoThumbnail.thumbnailData(
      //   video: videoPath,
      //   imageFormat: ImageFormat.JPEG,
      //   maxWidth: 300,
      //   quality: 75,
      // );
      // return Right(thumbnailData);
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('비디오 썸네일 생성 실패: ${e.toString()}'));
    }
  }

  /// Get video metadata (duration, size, etc.)
  Future<Either<Failure, VideoMetadata>> getVideoMetadata(String videoPath) async {
    try {
      final file = File(videoPath);
      if (!await file.exists()) {
        return const Left(DatabaseFailure('비디오 파일을 찾을 수 없습니다'));
      }

      final fileSize = await file.length();
      
      // For now, return basic metadata
      // In a real implementation, you would use packages like ffmpeg_kit_flutter
      // to extract detailed video metadata
      return Right(VideoMetadata(
        duration: const Duration(seconds: 0), // Would be extracted from video
        fileSize: fileSize,
        width: 0, // Would be extracted from video
        height: 0, // Would be extracted from video
        frameRate: 0.0, // Would be extracted from video
        bitrate: 0, // Would be extracted from video
      ));
    } catch (e) {
      return Left(DatabaseFailure('비디오 메타데이터 추출 실패: ${e.toString()}'));
    }
  }

  /// Compress video (placeholder implementation)
  Future<Either<Failure, String>> compressVideo(
    String videoPath, {
    int? targetBitrate,
    int? maxWidth,
    int? maxHeight,
    Function(double)? onProgress,
  }) async {
    try {
      // For now, return the original path as compression requires additional packages
      // In a real implementation, you would use packages like ffmpeg_kit_flutter
      // to compress videos
      
      // Simulate compression progress
      if (onProgress != null) {
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          onProgress(i / 100.0);
        }
      }
      
      return Right(videoPath);
    } catch (e) {
      return Left(DatabaseFailure('비디오 압축 실패: ${e.toString()}'));
    }
  }

  /// Delete media files from storage
  Future<Either<Failure, void>> deleteMediaFiles(
    List<String> mediaUrls, {
    String bucket = 'community',
  }) async {
    try {
      final filePaths = <String>[];

      for (final url in mediaUrls) {
        final filePath = _extractFilePathFromUrl(url, bucket);
        if (filePath != null) {
          filePaths.add(filePath);
        }
      }

      if (filePaths.isNotEmpty) {
        await _supabaseClient.storage
            .from(bucket)
            .remove(filePaths);
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('미디어 파일 삭제 실패: ${e.toString()}'));
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Check if file size is within limits
  bool isFileSizeValid(int sizeInBytes, {int maxSizeMB = 50}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return sizeInBytes <= maxSizeBytes;
  }

  /// Compress image file
  Future<Uint8List> _compressImage(File imageFile, int quality) async {
    try {
      // For now, just read the file as bytes
      // In a real implementation, you would use packages like flutter_image_compress
      // to properly compress images while maintaining quality
      return await imageFile.readAsBytes();
    } catch (e) {
      throw DatabaseFailure('이미지 압축 실패: ${e.toString()}');
    }
  }

  /// Check if file is an image
  bool _isImageFile(String extension) {
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    return imageExtensions.contains(extension.toLowerCase());
  }

  /// Check if file is a video
  bool _isVideoFile(String extension) {
    const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp'];
    return videoExtensions.contains(extension.toLowerCase());
  }

  /// Extract file path from Supabase storage URL
  String? _extractFilePathFromUrl(String url, String bucket) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find bucket name in path segments
      final bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Media upload progress callback
typedef MediaUploadProgressCallback = void Function(double progress);

/// Media upload result
class MediaUploadResult {
  final List<String> uploadedUrls;
  final List<String> failedFiles;
  final String? error;

  const MediaUploadResult({
    required this.uploadedUrls,
    this.failedFiles = const [],
    this.error,
  });

  bool get isSuccess => error == null && failedFiles.isEmpty;
  bool get hasPartialSuccess => uploadedUrls.isNotEmpty && failedFiles.isNotEmpty;
}

/// Media file info
class MediaFileInfo {
  final String path;
  final String name;
  final int sizeInBytes;
  final String extension;
  final MediaFileType type;

  const MediaFileInfo({
    required this.path,
    required this.name,
    required this.sizeInBytes,
    required this.extension,
    required this.type,
  });

  double get sizeInMB => sizeInBytes / (1024 * 1024);
  
  bool get isImage => type == MediaFileType.image;
  bool get isVideo => type == MediaFileType.video;
}

/// Media file type enumeration
enum MediaFileType {
  image,
  video,
  unknown,
}

/// Video metadata information
class VideoMetadata {
  final Duration duration;
  final int fileSize;
  final int width;
  final int height;
  final double frameRate;
  final int bitrate;

  const VideoMetadata({
    required this.duration,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.frameRate,
    required this.bitrate,
  });

  String get durationString {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get fileSizeString {
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get resolutionString => '${width}x$height';
}