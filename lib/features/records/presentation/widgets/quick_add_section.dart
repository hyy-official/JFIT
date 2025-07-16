import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/records/presentation/widgets/diet_add_sheet.dart';
import 'package:jfit/features/records/presentation/widgets/body_add_sheet.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/records/presentation/widgets/program_detail_sheet.dart';

/// Quick Add Section with Workout card spanning 2 columns
class QuickAddSection extends StatelessWidget {
  const QuickAddSection({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = (MediaQuery.of(context).size.width >= 1024) ? 16.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 추가',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: spacing / 2),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxWidth >= 768 ? 120.0 : 100.0;

            return Column(
              children: [
                // Workout card full width
                WorkoutCard(height: cardHeight),
                SizedBox(height: spacing),
                Row(
                  children: [
                    Expanded(child: QuickCard(icon: Icons.restaurant, label: '식단', accent: context.colors.success)),
                    SizedBox(width: spacing),
                    Expanded(child: QuickCard(icon: Icons.person, label: '신체', accent: context.colors.warning)),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class WorkoutCard extends StatefulWidget {
  final double height;
  const WorkoutCard({super.key, required this.height});

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  bool _hovering = false;
  CurrentWorkoutInfo? _cachedWorkoutInfo;

  @override
  void initState() {
    super.initState();
    print('🚀 [WorkoutCard] initState called');
    // 현재 운동 정보 로드
    _loadCurrentWorkoutInfo();
  }

  void _loadCurrentWorkoutInfo() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      print('🎯 [QuickAdd] Loading current workout info for user: ${authState.user.id}');
      context.read<RecordBloc>().add(LoadCurrentWorkoutInfo(userId: authState.user.id));
    } else {
      print('❌ [QuickAdd] User not authenticated');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 의존성이 변경될 때마다 운동 정보 다시 로드
    if (_cachedWorkoutInfo == null) {
      _loadCurrentWorkoutInfo();
    }
  }

  void _handleTap(CurrentWorkoutInfo workoutInfo) {
    if (workoutInfo.hasProgram && workoutInfo.userProgramId != null) {
      final progressPercent = workoutInfo.totalDays != null && workoutInfo.totalDays! > 0
          ? (workoutInfo.completedDays ?? 0) / workoutInfo.totalDays! * 100
          : 0.0;
      
      _showProgramDetailSheet(
        context, 
        workoutInfo.userProgramId!,
        workoutInfo.programName ?? '운동 프로그램',
        progressPercent,
      );
    } else {
      // 운동 프로그램이 없으면 프로그램 선택 화면으로 이동
      // TODO: 프로그램 선택 화면 구현
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        print('🎨 [WorkoutCard] BlocBuilder rebuild - State: ${state.runtimeType}');
        
        // 🎯 현재 운동 정보 가져오기
        CurrentWorkoutInfo workoutInfo = _cachedWorkoutInfo ?? const CurrentWorkoutInfo();
        
        // 새로운 운동 정보가 로드되면 캐시 업데이트
        if (state is CurrentWorkoutInfoLoaded) {
          print('✅ [WorkoutCard] CurrentWorkoutInfoLoaded received!');
          print('📋 [WorkoutCard] Workout info: ${state.workoutInfo.programName} - ${state.workoutInfo.progressText}');
          workoutInfo = state.workoutInfo;
          _cachedWorkoutInfo = workoutInfo;
        } else {
          print('ℹ️ [WorkoutCard] Using cached or default workout info: ${workoutInfo.progressText}');
        }

        return GestureDetector(
          onTap: () => _handleTap(workoutInfo),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: AnimatedScale(
              scale: _hovering ? 1.02 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: widget.height,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hovering ? context.colors.primary : context.colors.border, 
                    width: 1
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.outline.withOpacity(_hovering ? 0.25 : 0.15),
                      blurRadius: _hovering ? 16 : 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: workoutInfo.hasActiveSession 
                            ? LinearGradient(colors: [context.colors.success, context.colors.success.withOpacity(0.8)])
                            : context.colors.gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        workoutInfo.hasActiveSession ? Icons.play_circle_filled : Icons.fitness_center,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '운동',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workoutInfo.progressText,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      workoutInfo.hasProgram ? Icons.arrow_forward_ios : Icons.add,
                      color: context.colors.textPrimary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuickCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accent;
  const QuickCard({super.key, required this.icon, required this.label, required this.accent});

  @override
  State<QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<QuickCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      if (widget.label == '식단') {
        _showAddDietSheet(context);
      } else if (widget.label == '신체') {
        _showAddBodySheet(context);
      }
    }

    return GestureDetector(
      onTap: handleTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedScale(
          scale: _hovering ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface.withOpacity(0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _hovering ? widget.accent : context.colors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow.withOpacity(_hovering ? 0.25 : 0.15),
                  blurRadius: _hovering ? 16 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [widget.accent.withOpacity(0.8), widget.accent]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: context.colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showAddDietSheet(BuildContext context, {DateTime? date}) {
  final isDesktop = MediaQuery.of(context).size.width >= 1024;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DietAddSheetContent(selectedDate: date ?? DateTime.now()),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: DietAddSheetContent(selectedDate: date ?? DateTime.now()),
      ),
    );
  }
}

void _showAddBodySheet(BuildContext context, {DateTime? date}) {
  final isDesktop = MediaQuery.of(context).size.width >= 1024;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BodyAddSheetContent(selectedDate: date ?? DateTime.now()),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: BodyAddSheetContent(selectedDate: date ?? DateTime.now()),
      ),
    );
  }
}

void _showProgramDetailSheet(
  BuildContext context, 
  String userProgramId, 
  String programName, 
  double progressPercent,
) {
  final isDesktop = MediaQuery.of(context).size.width >= 1024;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: ProgramDetailSheet(
              userProgramId: userProgramId,
              programName: programName,
              progressPercent: progressPercent,
            ),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ProgramDetailSheet(
          userProgramId: userProgramId,
          programName: programName,
          progressPercent: progressPercent,
        ),
      ),
    );
  }
} 