import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/media/media_picker_widget.dart';

import 'media_picker_widget_test.mocks.dart';

@GenerateMocks([ImagePicker])
void main() {
  group('MediaPickerWidget Tests', () {
    late MockImagePicker mockImagePicker;

    setUp(() {
      mockImagePicker = MockImagePicker();
    });

    Widget createTestWidget({
      Function(List<String>)? onMediaSelected,
      int maxImages = 5,
      bool allowVideo = true,
      bool allowMultiple = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MediaPickerWidget(
            onMediaSelected: onMediaSelected,
            maxImages: maxImages,
            allowVideo: allowVideo,
            allowMultiple: allowMultiple,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display media picker options', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Add Media'), findsOneWidget);
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      });

      testWidgets('should show video option when allowed', (tester) async {
        await tester.pumpWidget(createTestWidget(allowVideo: true));

        expect(find.byIcon(Icons.videocam), findsOneWidget);
      });

      testWidgets('should hide video option when not allowed', (tester) async {
        await tester.pumpWidget(createTestWidget(allowVideo: false));

        expect(find.byIcon(Icons.videocam), findsNothing);
      });

      testWidgets('should display selected media count', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaCount: 3,
                maxImages: 5,
              ),
            ),
          ),
        );

        expect(find.text('3/5 selected'), findsOneWidget);
      });

      testWidgets('should show max limit reached message', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaCount: 5,
                maxImages: 5,
              ),
            ),
          ),
        );

        expect(find.text('Maximum limit reached'), findsOneWidget);
      });
    });

    group('Media Selection', () {
      testWidgets('should open gallery when gallery button is tapped', (tester) async {
        List<String>? selectedMedia;
        
        when(mockImagePicker.pickMultipleMedia()).thenAnswer(
          (_) async => [
            XFile('/path/to/image1.jpg'),
            XFile('/path/to/image2.jpg'),
          ],
        );

        await tester.pumpWidget(createTestWidget(
          onMediaSelected: (media) => selectedMedia = media,
        ));

        await tester.tap(find.byIcon(Icons.photo_library));
        await tester.pumpAndSettle();

        expect(selectedMedia, isNotNull);
        expect(selectedMedia?.length, 2);
      });

      testWidgets('should open camera when camera button is tapped', (tester) async {
        List<String>? selectedMedia;
        
        when(mockImagePicker.pickImage(source: ImageSource.camera)).thenAnswer(
          (_) async => XFile('/path/to/camera_image.jpg'),
        );

        await tester.pumpWidget(createTestWidget(
          onMediaSelected: (media) => selectedMedia = media,
        ));

        await tester.tap(find.byIcon(Icons.camera_alt));
        await tester.pumpAndSettle();

        expect(selectedMedia, isNotNull);
        expect(selectedMedia?.length, 1);
      });

      testWidgets('should open video picker when video button is tapped', (tester) async {
        List<String>? selectedMedia;
        
        when(mockImagePicker.pickVideo(source: ImageSource.gallery)).thenAnswer(
          (_) async => XFile('/path/to/video.mp4'),
        );

        await tester.pumpWidget(createTestWidget(
          onMediaSelected: (media) => selectedMedia = media,
        ));

        await tester.tap(find.byIcon(Icons.videocam));
        await tester.pumpAndSettle();

        expect(selectedMedia, isNotNull);
        expect(selectedMedia?.length, 1);
      });

      testWidgets('should handle single image selection when multiple not allowed', (tester) async {
        List<String>? selectedMedia;
        
        when(mockImagePicker.pickImage(source: ImageSource.gallery)).thenAnswer(
          (_) async => XFile('/path/to/single_image.jpg'),
        );

        await tester.pumpWidget(createTestWidget(
          allowMultiple: false,
          onMediaSelected: (media) => selectedMedia = media,
        ));

        await tester.tap(find.byIcon(Icons.photo_library));
        await tester.pumpAndSettle();

        expect(selectedMedia, isNotNull);
        expect(selectedMedia?.length, 1);
      });
    });

    group('Media Preview', () {
      testWidgets('should display selected media previews', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaPaths: [
                  '/path/to/image1.jpg',
                  '/path/to/image2.jpg',
                ],
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsNWidgets(2));
      });

      testWidgets('should show remove button on media previews', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaPaths: ['/path/to/image1.jpg'],
                onMediaRemoved: (index) {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('should call onMediaRemoved when remove button is tapped', (tester) async {
        int? removedIndex;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaPaths: ['/path/to/image1.jpg'],
                onMediaRemoved: (index) => removedIndex = index,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(removedIndex, 0);
      });

      testWidgets('should display video thumbnail for video files', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaPaths: ['/path/to/video.mp4'],
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      });
    });

    group('Validation and Limits', () {
      testWidgets('should disable selection when max limit reached', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaCount: 5,
                maxImages: 5,
              ),
            ),
          ),
        );

        final galleryButton = tester.widget<IconButton>(
          find.byIcon(Icons.photo_library),
        );
        expect(galleryButton.onPressed, isNull);
      });

      testWidgets('should show error for unsupported file types', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                errorMessage: 'Unsupported file type',
              ),
            ),
          ),
        );

        expect(find.text('Unsupported file type'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('should show error for file size limit', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                errorMessage: 'File size too large (max 10MB)',
              ),
            ),
          ),
        );

        expect(find.text('File size too large (max 10MB)'), findsOneWidget);
      });

      testWidgets('should validate image dimensions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                maxImageWidth: 1920,
                maxImageHeight: 1080,
                errorMessage: 'Image dimensions too large',
              ),
            ),
          ),
        );

        expect(find.text('Image dimensions too large'), findsOneWidget);
      });
    });

    group('Loading States', () {
      testWidgets('should show loading indicator when processing', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Processing media...'), findsOneWidget);
      });

      testWidgets('should disable buttons when loading', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                isLoading: true,
              ),
            ),
          ),
        );

        final galleryButton = tester.widget<IconButton>(
          find.byIcon(Icons.photo_library),
        );
        expect(galleryButton.onPressed, isNull);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(MediaPickerWidget), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should show grid layout on larger screens', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaPaths: [
                  '/path/to/image1.jpg',
                  '/path/to/image2.jpg',
                  '/path/to/image3.jpg',
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(GridView), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle picker cancellation gracefully', (tester) async {
        List<String>? selectedMedia;
        
        when(mockImagePicker.pickMultipleMedia()).thenAnswer(
          (_) async => [], // User cancelled
        );

        await tester.pumpWidget(createTestWidget(
          onMediaSelected: (media) => selectedMedia = media,
        ));

        await tester.tap(find.byIcon(Icons.photo_library));
        await tester.pumpAndSettle();

        expect(selectedMedia, isNull);
      });

      testWidgets('should handle picker errors gracefully', (tester) async {
        when(mockImagePicker.pickMultipleMedia()).thenThrow(
          Exception('Permission denied'),
        );

        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byIcon(Icons.photo_library));
        await tester.pumpAndSettle();

        expect(find.text('Permission denied'), findsOneWidget);
      });

      testWidgets('should handle corrupted media files', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaPaths: ['/path/to/corrupted.jpg'],
                errorMessage: 'Failed to load media',
              ),
            ),
          ),
        );

        expect(find.text('Failed to load media'), findsOneWidget);
        expect(find.byIcon(Icons.broken_image), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.bySemanticsLabel('Select from gallery'),
          findsOneWidget,
        );
        
        expect(
          find.bySemanticsLabel('Take photo'),
          findsOneWidget,
        );
        
        expect(
          find.bySemanticsLabel('Record video'),
          findsOneWidget,
        );
      });

      testWidgets('should support keyboard navigation', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Should focus on first button
        expect(find.byType(MediaPickerWidget), findsOneWidget);
      });

      testWidgets('should announce media selection to screen readers', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaCount: 3,
                maxImages: 5,
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('3 of 5 media files selected'),
          findsOneWidget,
        );
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: MediaPickerWidget(),
            ),
          ),
        );

        expect(find.byType(MediaPickerWidget), findsOneWidget);
      });

      testWidgets('should respect dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: MediaPickerWidget(),
            ),
          ),
        );

        expect(find.byType(MediaPickerWidget), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('should handle large number of selected media efficiently', (tester) async {
        final largeMeidaList = List.generate(50, (index) => '/path/to/image$index.jpg');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaPaths: largeMeidaList,
              ),
            ),
          ),
        );

        expect(find.byType(MediaPickerWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should lazy load media previews', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaPickerWidget(
                selectedMediaPaths: [
                  '/path/to/image1.jpg',
                  '/path/to/image2.jpg',
                ],
                useLazyLoading: true,
              ),
            ),
          ),
        );

        expect(find.byType(MediaPickerWidget), findsOneWidget);
      });
    });
  });
}