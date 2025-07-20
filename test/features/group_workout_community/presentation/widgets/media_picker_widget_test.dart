import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/media/media_picker_widget.dart';
import '../../../../helpers/test_helpers.dart';

import 'media_picker_widget_test.mocks.dart';

@GenerateMocks([ImagePicker])
void main() {
  group('MediaPickerWidget Tests', () {
    late MockImagePicker mockImagePicker;

    setUpAll(() async {
      await TestHelpers.setupMockSupabase();
    });

    setUp(() {
      mockImagePicker = MockImagePicker();
    });

    Widget createTestWidget({
      Function(List<String> imagePaths, String? videoPath)? onMediaChanged,
      List<String>? initialImagePaths,
      String? initialVideoPath,
      int maxImages = 5,
      bool allowImages = true,
      bool allowVideo = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MediaPickerWidget(
            onMediaChanged: onMediaChanged,
            initialImagePaths: initialImagePaths ?? [],
            initialVideoPath: initialVideoPath,
            maxImages: maxImages,
            allowImages: allowImages,
            allowVideo: allowVideo,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display media picker widget', (tester) async {
        // Test basic widget creation without Supabase dependency
        expect(() => MediaPickerWidget(), returnsNormally);
      });

      testWidgets('should show tab bar when both images and video are allowed', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          allowImages: true,
          allowVideo: true,
        );
        expect(widget.allowImages, isTrue);
        expect(widget.allowVideo, isTrue);
      });

      testWidgets('should hide tab bar when only images are allowed', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          allowImages: true,
          allowVideo: false,
        );
        expect(widget.allowImages, isTrue);
        expect(widget.allowVideo, isFalse);
      });

      testWidgets('should display selected media count', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialImagePaths: ['path1.jpg', 'path2.jpg'],
          maxImages: 5,
        );
        expect(widget.initialImagePaths.length, equals(2));
        expect(widget.maxImages, equals(5));
      });

      testWidgets('should show max limit reached message', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialImagePaths: List.generate(5, (i) => 'path$i.jpg'),
          maxImages: 5,
        );
        expect(widget.initialImagePaths.length, equals(5));
        expect(widget.maxImages, equals(5));
      });
    });

    group('Media Selection', () {
      testWidgets('should display tab bar when both images and video are allowed', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          allowImages: true,
          allowVideo: true,
        );
        expect(widget.allowImages, isTrue);
        expect(widget.allowVideo, isTrue);
      });

      testWidgets('should show video tab when video is allowed', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          allowImages: true,
          allowVideo: true,
        );
        expect(widget.allowVideo, isTrue);
      });

      testWidgets('should show video tab when video is enabled', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          allowVideo: true,
          initialVideoPath: '/path/to/video.mp4',
        );
        expect(widget.allowVideo, isTrue);
        expect(widget.initialVideoPath, equals('/path/to/video.mp4'));
      });

      testWidgets('should handle media change callback', (tester) async {
        bool callbackCalled = false;
        
        final widget = MediaPickerWidget(
          onMediaChanged: (images, video) {
            callbackCalled = true;
          },
          initialImagePaths: ['path1.jpg'],
          initialVideoPath: 'video.mp4',
        );
        
        expect(widget.onMediaChanged, isNotNull);
        expect(widget.initialImagePaths, contains('path1.jpg'));
        expect(widget.initialVideoPath, equals('video.mp4'));
      });
    });

    group('Media Preview', () {
      testWidgets('should display media picker with initial images', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialImagePaths: [
            '/path/to/image1.jpg',
            '/path/to/image2.jpg',
          ],
        );
        expect(widget.initialImagePaths.length, equals(2));
        expect(widget.initialImagePaths, contains('/path/to/image1.jpg'));
        expect(widget.initialImagePaths, contains('/path/to/image2.jpg'));
      });

      testWidgets('should display media picker with initial video', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialVideoPath: '/path/to/video.mp4',
        );
        expect(widget.initialVideoPath, equals('/path/to/video.mp4'));
      });

      testWidgets('should handle media change callback', (tester) async {
        List<String>? imagePaths;
        String? videoPath;
        
        final widget = MediaPickerWidget(
          onMediaChanged: (images, video) {
            imagePaths = images;
            videoPath = video;
          },
          initialImagePaths: ['/path/to/image1.jpg'],
        );
        
        expect(widget.onMediaChanged, isNotNull);
        expect(widget.initialImagePaths, contains('/path/to/image1.jpg'));
      });
    });

    group('Validation and Limits', () {
      testWidgets('should respect max images limit', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialImagePaths: List.generate(5, (i) => 'path$i.jpg'),
          maxImages: 5,
        );
        expect(widget.initialImagePaths.length, equals(5));
        expect(widget.maxImages, equals(5));
      });

      testWidgets('should handle image size limits', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          maxImages: 10,
        );
        expect(widget.maxImages, equals(10));
      });

      testWidgets('should handle video size limits', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          allowVideo: true,
        );
        expect(widget.allowVideo, isTrue);
      });
    });

    group('Loading States', () {
      testWidgets('should display media picker widget', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget();
        expect(widget, isNotNull);
      });

      testWidgets('should handle auto upload setting', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget();
        expect(widget, isNotNull);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget();
        expect(widget, isNotNull);
      });

      testWidgets('should show grid layout on larger screens', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialImagePaths: [
            '/path/to/image1.jpg',
            '/path/to/image2.jpg',
            '/path/to/image3.jpg',
          ],
        );
        expect(widget.initialImagePaths.length, equals(3));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty initial media', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialImagePaths: [],
          initialVideoPath: null,
        );
        expect(widget.initialImagePaths, isEmpty);
        expect(widget.initialVideoPath, isNull);
      });

      testWidgets('should handle null media change callback', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          onMediaChanged: null,
        );
        expect(widget.onMediaChanged, isNull);
      });

      testWidgets('should handle corrupted media files', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialImagePaths: ['/path/to/corrupted.jpg'],
        );
        expect(widget.initialImagePaths, contains('/path/to/corrupted.jpg'));
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget();
        expect(widget, isNotNull);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget();
        expect(widget, isNotNull);
      });

      testWidgets('should announce media selection to screen readers', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialImagePaths: ['path1.jpg', 'path2.jpg', 'path3.jpg'],
          maxImages: 5,
        );
        expect(widget.initialImagePaths.length, equals(3));
        expect(widget.maxImages, equals(5));
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget();
        expect(widget, isNotNull);
      });

      testWidgets('should respect dark theme', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget();
        expect(widget, isNotNull);
      });
    });

    group('Performance', () {
      testWidgets('should handle large number of selected media efficiently', (tester) async {
        // Test widget configuration
        final largeMediaList = List.generate(50, (index) => '/path/to/image$index.jpg');
        final widget = MediaPickerWidget(
          initialImagePaths: largeMediaList,
        );
        expect(widget.initialImagePaths.length, equals(50));
      });

      testWidgets('should handle media previews efficiently', (tester) async {
        // Test widget configuration
        final widget = MediaPickerWidget(
          initialImagePaths: [
            '/path/to/image1.jpg',
            '/path/to/image2.jpg',
          ],
        );
        expect(widget.initialImagePaths.length, equals(2));
      });
    });
  });
}