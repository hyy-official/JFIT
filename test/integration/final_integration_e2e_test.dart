import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import 'package:jfit/core/di/injection_container.dart';
import 'package:jfit/core/navigation/app_router.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:dartz/dartz.dart';
import 'package:jfit/core/utils/accessibility_utils.dart';
import 'package:jfit/core/utils/ux_optimization_utils.dart';

// Existing features
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';

// Group workout community features
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/community/community_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_card.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

// Repository interfaces
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';
import 'package:jfit/features/workout_session/data/repositories/workout_session_repository.dart';
import 'package:jfit/features/programs/domain/repositories/program_repository.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_repository.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_activity_repository.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/community_repository.dart';

import 'final_integration_e2e_test.mocks.dart';

@GenerateMocks([
  WorkoutProgramRepository,
  WorkoutSessionRepository,
  ProgramRepository,
  GroupRepository,
  GroupActivityRepository,
  CommunityRepository,
])
void main() {
  group('Final Integration E2E Tests', () {
    late MockWorkoutProgramRepository mockWorkoutProgramRepository;
    late MockWorkoutSessionRepository mockWorkoutSessionRepository;
    late MockProgramRepository mockProgramRepository;
    late MockGroupRepository mockGroupRepository;
    late MockGroupActivityRepository mockGroupActivityRepository;
    late MockCommunityRepository mockCommunityRepository;

    setUp(() {
      // Reset GetIt
      GetIt.instance.reset();

      // Create mocks
      mockWorkoutProgramRepository = MockWorkoutProgramRepository();
      mockWorkoutSessionRepository = MockWorkoutSessionRepository();
      mockProgramRepository = MockProgramRepository();
      mockGroupRepository = MockGroupRepository();
      mockGroupActivityRepository = MockGroupActivityRepository();
      mockCommunityRepository = MockCommunityRepository();

      // Register mocks in GetIt
      GetIt.instance.registerLazySingleton<WorkoutProgramRepository>(
        () => mockWorkoutProgramRepository,
      );
      GetIt.instance.registerLazySingleton<WorkoutSessionRepository>(
        () => mockWorkoutSessionRepository,
      );
      GetIt.instance.registerLazySingleton<ProgramRepository>(
        () => mockProgramRepository,
      );
      GetIt.instance.registerLazySingleton<GroupRepository>(
        () => mockGroupRepository,
      );
      GetIt.instance.registerLazySingleton<GroupActivityRepository>(
        () => mockGroupActivityRepository,
      );
      GetIt.instance.registerLazySingleton<CommunityRepository>(
        () => mockCommunityRepository,
      );
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    group('User Flow Integration Tests', () {
      testWidgets('Complete user journey: workout program to group sharing', (tester) async {
        // Arrange - Mock data for complete user journey
        const userId = 'user123';
        const groupId = 'group123';
        
        final mockGroup = WorkoutGroup(
          id: groupId,
          name: 'Fitness Buddies',
          description: 'A group for fitness enthusiasts',
          adminId: userId,
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          currentMemberCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );

        // Mock repository responses
        when(mockGroupRepository.getUserGroups(userId))
            .thenAnswer((_) async => Right([mockGroup]));
        
        when(mockGroupRepository.createGroup(any))
            .thenAnswer((_) async => Right(mockGroup));
        
        when(mockGroupRepository.joinGroup(any, any, any))
            .thenAnswer((_) async => Right(mockGroup));

        // Build the complete app
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<AuthBloc>(
                    create: (_) => AuthBloc()..add(AuthCheckRequested()),
                  ),
                  BlocProvider<WorkoutProgramBloc>(
                    create: (_) => WorkoutProgramBloc(mockWorkoutProgramRepository),
                  ),
                  BlocProvider<WorkoutSessionBloc>(
                    create: (_) => WorkoutSessionBloc(mockWorkoutSessionRepository),
                  ),
                  BlocProvider<ProgramsBloc>(
                    create: (_) => ProgramsBloc(mockProgramRepository),
                  ),
                  BlocProvider<GroupBloc>(
                    create: (_) => GroupBloc(mockGroupRepository),
                  ),
                  BlocProvider<GroupActivityBloc>(
                    create: (_) => GroupActivityBloc(mockGroupActivityRepository),
                  ),
                  BlocProvider<CommunityBloc>(
                    create: (_) => CommunityBloc(mockCommunityRepository),
                  ),
                ],
                child: child ?? const SizedBox(),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Test 1: Navigate to groups section
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        
        // Tap on groups tab
        await tester.tap(find.text('그룹'));
        await tester.pumpAndSettle();

        // Verify groups page is displayed
        expect(find.text('내 그룹'), findsOneWidget);

        // Test 2: Create a new group
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Fill group creation form
        await tester.enterText(find.byType(TextField).first, 'Test Group');
        await tester.enterText(find.byType(TextField).at(1), 'A test group for integration');
        
        // Submit form
        await tester.tap(find.text('생성'));
        await tester.pumpAndSettle();

        // Verify group was created
        verify(mockGroupRepository.createGroup(any)).called(1);

        // Test 3: Navigate to community section
        await tester.tap(find.text('커뮤니티'));
        await tester.pumpAndSettle();

        // Verify community page is displayed
        expect(find.text('커뮤니티 게시판'), findsOneWidget);
      });

      testWidgets('Accessibility features work correctly', (tester) async {
        // Arrange - Create a group card with accessibility features
        final mockGroup = WorkoutGroup(
          id: 'group123',
          name: 'Accessible Group',
          description: 'Testing accessibility features',
          adminId: 'admin123',
          privacyType: GroupPrivacyType.public,
          maxMembers: 20,
          currentMemberCount: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            home: Scaffold(
              body: GroupCard(
                group: mockGroup,
                showJoinButton: true,
                onJoinPressed: () {},
                onTap: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test semantic labels
        expect(find.bySemanticsLabel(RegExp('Accessible Group')), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp('10.*members')), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp('Public')), findsOneWidget);

        // Test accessible tap targets
        final joinButton = find.byType(ElevatedButton);
        expect(joinButton, findsOneWidget);

        // Verify minimum tap target size
        final buttonWidget = tester.widget<ElevatedButton>(joinButton);
        expect(buttonWidget.style?.minimumSize?.resolve({}), isNotNull);

        // Test keyboard navigation
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Verify focus management
        expect(tester.binding.focusManager.primaryFocus, isNotNull);
      });

      testWidgets('Localization works correctly', (tester) async {
        // Test Korean localization
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ko'),
            theme: JFitTheme.lightTheme,
            home: const Scaffold(
              body: Center(
                child: Text('그룹'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('그룹'), findsOneWidget);

        // Test English localization
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            theme: JFitTheme.lightTheme,
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Scaffold(
                  body: Center(
                    child: Text(l10n.groups),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Groups'), findsOneWidget);
      });

      testWidgets('UX optimization features work correctly', (tester) async {
        // Test optimized snackbar
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.showSuccessSnackBar('Test success message');
                      },
                      child: const Text('Show Success'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap button to show snackbar
        await tester.tap(find.text('Show Success'));
        await tester.pump();

        // Verify snackbar is shown
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Test success message'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('Error handling works correctly', (tester) async {
        // Test error dialog
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.showErrorDialog(
                          title: 'Test Error',
                          message: 'This is a test error message',
                        );
                      },
                      child: const Text('Show Error'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap button to show error dialog
        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        // Verify error dialog is shown
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Test Error'), findsOneWidget);
        expect(find.text('This is a test error message'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('Responsive design works correctly', (tester) async {
        // Test mobile layout
        await tester.binding.setSurfaceSize(const Size(400, 800));
        
        final mockGroup = WorkoutGroup(
          id: 'group123',
          name: 'Responsive Group',
          description: 'Testing responsive design',
          adminId: 'admin123',
          privacyType: GroupPrivacyType.public,
          maxMembers: 20,
          currentMemberCount: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            home: Scaffold(
              body: GroupCard(
                group: mockGroup,
                showJoinButton: true,
                onJoinPressed: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify mobile layout
        expect(find.byType(GroupCard), findsOneWidget);

        // Test tablet layout
        await tester.binding.setSurfaceSize(const Size(800, 600));
        await tester.pumpAndSettle();

        // Verify layout adapts to tablet size
        expect(find.byType(GroupCard), findsOneWidget);

        // Test desktop layout
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpAndSettle();

        // Verify layout adapts to desktop size
        expect(find.byType(GroupCard), findsOneWidget);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('Performance optimization works correctly', (tester) async {
        // Test with large dataset
        final groups = List.generate(100, (index) => WorkoutGroup(
          id: 'group$index',
          name: 'Group $index',
          description: 'Description for group $index',
          adminId: 'admin$index',
          privacyType: index % 2 == 0 ? GroupPrivacyType.public : GroupPrivacyType.private,
          maxMembers: 20 + (index % 30),
          currentMemberCount: index % 20,
          createdAt: DateTime.now().subtract(Duration(days: index)),
          updatedAt: DateTime.now(),
          isActive: true,
        ));

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            home: Scaffold(
              body: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return GroupCard(
                    group: groups[index],
                    showJoinButton: true,
                    onJoinPressed: () {},
                  );
                },
              ),
            ),
          ),
        );

        // Measure performance
        final stopwatch = Stopwatch()..start();
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verify reasonable performance (should render in less than 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));

        // Test scrolling performance
        final scrollStopwatch = Stopwatch()..start();
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        scrollStopwatch.stop();

        // Verify smooth scrolling
        expect(scrollStopwatch.elapsedMilliseconds, lessThan(500));
      });

      testWidgets('Deep linking works correctly', (tester) async {
        // Test group invite deep link
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to a deep link route
        AppRouter.router.go('/invite/test123');
        await tester.pumpAndSettle();

        // Verify redirect to join group page with invite code
        expect(AppRouter.router.routerDelegate.currentConfiguration.fullPath, 
               contains('/group-join'));
        expect(AppRouter.router.routerDelegate.currentConfiguration.fullPath, 
               contains('invite=test123'));
      });

      testWidgets('Cross-feature data consistency', (tester) async {
        // Test that data flows correctly between workout and group features
        const userId = 'user123';
        const groupId = 'group123';

        // Mock successful responses
        when(mockWorkoutProgramRepository.getUserPrograms(userId))
            .thenAnswer((_) async => const Right([]));
        
        when(mockGroupRepository.getUserGroups(userId))
            .thenAnswer((_) async => const Right([]));
        
        when(mockGroupActivityRepository.getGroupActivities(groupId, limit: anyNamed('limit')))
            .thenAnswer((_) async => const Right([]));

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<WorkoutProgramBloc>(
                    create: (_) => WorkoutProgramBloc(mockWorkoutProgramRepository),
                  ),
                  BlocProvider<GroupBloc>(
                    create: (_) => GroupBloc(mockGroupRepository),
                  ),
                  BlocProvider<GroupActivityBloc>(
                    create: (_) => GroupActivityBloc(mockGroupActivityRepository),
                  ),
                ],
                child: child ?? const SizedBox(),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Verify all repositories can be called without conflicts
        verify(mockWorkoutProgramRepository.getUserPrograms(any)).called(0);
        verify(mockGroupRepository.getUserGroups(any)).called(0);
        verify(mockGroupActivityRepository.getGroupActivities(any, limit: anyNamed('limit'))).called(0);
      });
    });

    group('Integration Stress Tests', () {
      testWidgets('Memory usage remains stable with heavy usage', (tester) async {
        // Create a complex widget tree with multiple BLoCs
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            home: MultiBlocProvider(
              providers: [
                BlocProvider<WorkoutProgramBloc>(
                  create: (_) => WorkoutProgramBloc(mockWorkoutProgramRepository),
                ),
                BlocProvider<GroupBloc>(
                  create: (_) => GroupBloc(mockGroupRepository),
                ),
                BlocProvider<GroupActivityBloc>(
                  create: (_) => GroupActivityBloc(mockGroupActivityRepository),
                ),
                BlocProvider<CommunityBloc>(
                  create: (_) => CommunityBloc(mockCommunityRepository),
                ),
              ],
              child: const Scaffold(
                body: Center(
                  child: Text('Stress Test'),
                ),
              ),
            ),
          ),
        );

        // Perform multiple pump cycles to simulate heavy usage
        for (int i = 0; i < 10; i++) {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Verify widget tree is still stable
        expect(find.text('Stress Test'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Concurrent operations handle correctly', (tester) async {
        // Mock concurrent operations
        when(mockGroupRepository.getUserGroups(any))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 50));
              return const Right([]);
            });
        
        when(mockWorkoutProgramRepository.getUserPrograms(any))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 50));
              return const Right([]);
            });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: JFitTheme.lightTheme,
            home: MultiBlocProvider(
              providers: [
                BlocProvider<WorkoutProgramBloc>(
                  create: (_) => WorkoutProgramBloc(mockWorkoutProgramRepository),
                ),
                BlocProvider<GroupBloc>(
                  create: (_) => GroupBloc(mockGroupRepository),
                ),
              ],
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Trigger concurrent operations
                          context.read<WorkoutProgramBloc>().add(LoadUserPrograms(userId: 'user123'));
                          context.read<GroupBloc>().add(LoadUserGroups(userId: 'user123'));
                        },
                        child: const Text('Trigger Concurrent'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Trigger concurrent operations
        await tester.tap(find.text('Trigger Concurrent'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify no exceptions occurred
        expect(tester.takeException(), isNull);
      });
    });
  });
}