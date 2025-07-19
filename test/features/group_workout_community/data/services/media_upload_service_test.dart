import 'package:flutter_test/flutter_test.dart';

import 'package:jfit/features/group_workout_community/data/services/media_upload_service.dart';

void main() {
  group('MediaUploadService', () {
    // Test data classes and utility functions without initializing the service
    // since it requires Supabase initialization

    group('VideoMetadata', () {
      test('should format duration string correctly', () {
        // Test various durations
        final metadata1 = VideoMetadata(
          duration: const Duration(minutes: 2, seconds: 30),
          fileSize: 1024,
          width: 1920,
          height: 1080,
          frameRate: 30.0,
          bitrate: 5000,
        );
        expect(metadata1.durationString, equals('02:30'));

        final metadata2 = VideoMetadata(
          duration: const Duration(minutes: 0, seconds: 5),
          fileSize: 1024,
          width: 1920,
          height: 1080,
          frameRate: 30.0,
          bitrate: 5000,
        );
        expect(metadata2.durationString, equals('00:05'));

        final metadata3 = VideoMetadata(
          duration: const Duration(minutes: 15, seconds: 0),
          fileSize: 1024,
          width: 1920,
          height: 1080,
          frameRate: 30.0,
          bitrate: 5000,
        );
        expect(metadata3.durationString, equals('15:00'));
      });

      test('should format file size string correctly', () {
        // Test KB size
        final metadata1 = VideoMetadata(
          duration: Duration.zero,
          fileSize: 512 * 1024, // 512KB
          width: 1920,
          height: 1080,
          frameRate: 30.0,
          bitrate: 5000,
        );
        expect(metadata1.fileSizeString, equals('512.0KB'));

        // Test MB size
        final metadata2 = VideoMetadata(
          duration: Duration.zero,
          fileSize: 5 * 1024 * 1024, // 5MB
          width: 1920,
          height: 1080,
          frameRate: 30.0,
          bitrate: 5000,
        );
        expect(metadata2.fileSizeString, equals('5.0MB'));
      });

      test('should format resolution string correctly', () {
        final metadata = VideoMetadata(
          duration: Duration.zero,
          fileSize: 1024,
          width: 1920,
          height: 1080,
          frameRate: 30.0,
          bitrate: 5000,
        );
        expect(metadata.resolutionString, equals('1920x1080'));
      });
    });

    group('MediaFileInfo', () {
      test('should calculate size in MB correctly', () {
        final fileInfo = MediaFileInfo(
          path: '/path/to/file.jpg',
          name: 'file.jpg',
          sizeInBytes: 2 * 1024 * 1024, // 2MB
          extension: '.jpg',
          type: MediaFileType.image,
        );
        
        expect(fileInfo.sizeInMB, closeTo(2.0, 0.01));
      });

      test('should identify file types correctly', () {
        final imageFile = MediaFileInfo(
          path: '/path/to/image.jpg',
          name: 'image.jpg',
          sizeInBytes: 1024,
          extension: '.jpg',
          type: MediaFileType.image,
        );
        expect(imageFile.isImage, isTrue);
        expect(imageFile.isVideo, isFalse);

        final videoFile = MediaFileInfo(
          path: '/path/to/video.mp4',
          name: 'video.mp4',
          sizeInBytes: 1024,
          extension: '.mp4',
          type: MediaFileType.video,
        );
        expect(videoFile.isVideo, isTrue);
        expect(videoFile.isImage, isFalse);
      });
    });

    group('MediaUploadResult', () {
      test('should identify success state correctly', () {
        const result1 = MediaUploadResult(
          uploadedUrls: ['url1', 'url2'],
          failedFiles: [],
        );
        expect(result1.isSuccess, isTrue);
        expect(result1.hasPartialSuccess, isFalse);

        const result2 = MediaUploadResult(
          uploadedUrls: ['url1'],
          failedFiles: ['file2'],
        );
        expect(result2.isSuccess, isFalse);
        expect(result2.hasPartialSuccess, isTrue);

        const result3 = MediaUploadResult(
          uploadedUrls: [],
          failedFiles: ['file1'],
          error: 'Upload failed',
        );
        expect(result3.isSuccess, isFalse);
        expect(result3.hasPartialSuccess, isFalse);
      });
    });
  });
}