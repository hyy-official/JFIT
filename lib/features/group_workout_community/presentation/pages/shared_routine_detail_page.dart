import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_state.dart';
import 'package:jfit/features/group_workout_community/domain/entities/shared_routine.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_activity_repository.dart';

/// 공유된 루틴 상세 화면 - 운동 내용, 복사 기능
class SharedRoutineDetailPage extends StatefulWidget {
  final String sharedRoutineId;

  const SharedRoutineDetailPage({
    super.key,
    required this.sharedRoutineId,
  });

  @override
  State<SharedRoutineDetailPage> createState() => _SharedRoutineDetailPageState();
}

class _SharedRoutineDetailPageState extends State<SharedRoutineDetailPage> {
  SharedRoutine? _sharedRoutine;
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;
  bool _isCopying = false;

  @override
  void initState() {
    super.initState();
    _loadSharedRoutine();
    _setupBlocListener();
  }

  void _setupBlocListener() {
    context.read<GroupActivityBloc>().stream.listen((state) {
      if (mounted) {
        if (state is GroupActivitiesLoaded) {
          _handleRoutineLoaded(state);
        } else if (state is RoutineCopied) {
          _handleRoutineCopied(state);
        } else if (state is GroupActivityErrorState) {
          _handleError(state);
        } else if (state is GroupActivityLoading) {
          setState(() {
            if (state.operationType == 'loading_shared_routine') {
              _isLoading = true;
            } else if (state.operationType == 'copying_routine') {
              _isCopying = true;
            }
          });
        }
      }
    });
  }

  void _loadSharedRoutine() {
    context.read<GroupActivityBloc>().add(LoadGroupActivities(
      groupId: 'shared_routine_group', // TODO: Get actual group ID
      limit: 50,
      offset: 0,
    ));
  }

  void _handleRoutineLoaded(GroupActivitiesLoaded state) {
    setState(() {
      // TODO: Extract shared routine and exercises from state
      // _sharedRoutine = state.sharedRoutine;
      // _exercises = state.exercises;
      _isLoading = false;
    });
  }

  void _handleRoutineCopied(RoutineCopied state) {
    setState(() {
      _isCopying = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_sharedRoutine?.routineName ?? '루틴'}이 내 프로그램에 복사되었습니다!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: '확인',
          onPressed: () {
            // TODO: Navigate to user's programs
          },
        ),
      ),
    );
  }

  void _handleError(GroupActivityErrorState state) {
    setState(() {
      _isLoading = false;
      _isCopying = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.userMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _copyRoutine() {
    if (_sharedRoutine == null) return;

    final request = ShareRoutineRequest(
      groupId: 'current_group_id', // TODO: Get from context
      userId: 'current_user_id', // TODO: Get from auth service
      userProgramId: widget.sharedRoutineId,
      routineName: _sharedRoutine?.routineName ?? 'Routine',
      description: _sharedRoutine?.description,
      exerciseIds: const [], // TODO: Get exercise IDs
    );
    
    context.read<GroupActivityBloc>().add(ShareRoutine(request));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('루틴 상세')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_sharedRoutine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('루틴 상세')),
        body: const Center(
          child: Text('루틴을 찾을 수 없습니다'),
        ),
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sharedRoutine!.routineName),
        actions: [
          IconButton(
            onPressed: () => _shareRoutine(),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRoutineHeader(),
            _buildExerciseList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCopying ? null : _copyRoutine,
        icon: _isCopying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.copy),
        label: Text(_isCopying ? '복사 중...' : '내 프로그램에 복사'),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sharedRoutine!.routineName),
        actions: [
          ElevatedButton.icon(
            onPressed: _isCopying ? null : _copyRoutine,
            icon: _isCopying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.copy),
            label: Text(_isCopying ? '복사 중...' : '복사'),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _shareRoutine(),
            icon: const Icon(Icons.share),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left side - Routine info
          SizedBox(
            width: 320,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: _buildRoutineHeader(),
            ),
          ),
          // Right side - Exercise list
          Expanded(
            child: _buildExerciseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sharedRoutine!.routineName),
        actions: [
          ElevatedButton.icon(
            onPressed: _isCopying ? null : _copyRoutine,
            icon: _isCopying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.copy),
            label: Text(_isCopying ? '복사' : '내 프로그램에 복사'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _shareRoutine(),
            icon: const Icon(Icons.share),
            label: const Text('공유'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left side - Routine info and stats
          SizedBox(
            width: 350,
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: _buildRoutineHeader(),
                ),
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildRoutineStats(),
                ),
              ],
            ),
          ),
          // Right side - Exercise list
          Expanded(
            child: _buildExerciseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shared by info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '공유자 이름', // TODO: Get actual sharer name
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(_sharedRoutine!.sharedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Routine name
          Text(
            _sharedRoutine!.routineName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          if (_sharedRoutine!.description?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              _sharedRoutine!.description!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Stats
          Row(
            children: [
              _buildStatChip(
                Icons.fitness_center,
                '${_exercises.length}개 운동',
                colorScheme.primary,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.favorite,
                '${_sharedRoutine!.likesCount}',
                Colors.red,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.copy,
                '${_sharedRoutine!.copiesCount}',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineStats() {
    final theme = Theme.of(context);
    
    // Calculate routine stats
    final totalSets = _exercises.fold<int>(
      0,
      (sum, exercise) => sum + (exercise['sets'] as int? ?? 0),
    );
    
    final estimatedDuration = _exercises.length * 3; // Rough estimate
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '루틴 통계',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildStatRow('총 운동 수', '${_exercises.length}개'),
          _buildStatRow('총 세트 수', '$totalSets세트'),
          _buildStatRow('예상 시간', '${estimatedDuration}분'),
          _buildStatRow('좋아요', '${_sharedRoutine!.likesCount}개'),
          _buildStatRow('복사 횟수', '${_sharedRoutine!.copiesCount}회'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_exercises.isEmpty) {
      return const Center(
        child: Text('운동 정보를 불러올 수 없습니다'),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '운동 목록',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return _buildExerciseItem(exercise, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(Map<String, dynamic> exercise, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.secondaryContainer,
        child: Text(
          index.toString(),
          style: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        exercise['name'] ?? '운동 ${index}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise['description'] != null) ...[
            Text(exercise['description']),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              if (exercise['sets'] != null) ...[
                Icon(
                  Icons.repeat,
                  size: 14,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${exercise['sets']}세트',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (exercise['reps'] != null) ...[
                Icon(
                  Icons.fitness_center,
                  size: 14,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${exercise['reps']}회',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (exercise['weight'] != null) ...[
                Icon(
                  Icons.monitor_weight,
                  size: 14,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${exercise['weight']}kg',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () => _showExerciseDetail(exercise),
        icon: const Icon(Icons.info_outline),
      ),
    );
  }

  void _shareRoutine() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능 구현 예정')),
    );
  }

  void _showExerciseDetail(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise['name'] ?? '운동 상세'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise['description'] != null) ...[
              Text(exercise['description']),
              const SizedBox(height: 12),
            ],
            if (exercise['sets'] != null)
              Text('세트: ${exercise['sets']}'),
            if (exercise['reps'] != null)
              Text('반복: ${exercise['reps']}회'),
            if (exercise['weight'] != null)
              Text('무게: ${exercise['weight']}kg'),
            if (exercise['rest_time'] != null)
              Text('휴식: ${exercise['rest_time']}초'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else {
      return '방금 전';
    }
  }
}