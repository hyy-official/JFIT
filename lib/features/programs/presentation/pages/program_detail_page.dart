import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/widgets/responsive_scaffold.dart';
import 'package:jfit/core/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';

class ProgramDetailPage extends StatefulWidget {
  final Map<String, dynamic> program;

  const ProgramDetailPage({super.key, required this.program});

  @override
  State<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends State<ProgramDetailPage> {
  int selectedWeek = 1;
  int weekPageStart = 0;
  int weeksPerPage = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateWeeksPerPage();
    });
  }

  void _updateWeeksPerPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      weeksPerPage = screenWidth < 768 ? 3 : 5;
    });
  }

  List<int> get currentWeeks {
    final totalWeeks = widget.program['duration_weeks'] as int;
    final weeks = <int>[];
    for (int i = weekPageStart; i < (weekPageStart + weeksPerPage).clamp(0, totalWeeks); i++) {
      weeks.add(i + 1);
    }
    return weeks;
  }

  void _scrollLeft() {
    setState(() {
      weekPageStart = (weekPageStart - weeksPerPage).clamp(0, double.infinity).toInt();
    });
  }

  void _scrollRight() {
    final totalWeeks = widget.program['duration_weeks'] as int;
    final maxWeekPageStart = (totalWeeks - weeksPerPage).clamp(0, double.infinity).toInt();
    setState(() {
      weekPageStart = (weekPageStart + weeksPerPage).clamp(0, maxWeekPageStart).toInt();
    });
  }

  int get totalPages {
    final totalWeeks = widget.program['duration_weeks'] as int;
    return (totalWeeks / weeksPerPage).ceil();
  }

  int get currentPageIndex {
    return (weekPageStart / weeksPerPage).floor();
  }

  Map<String, dynamic> get currentWeekSchedule {
    final weeklySchedule = widget.program['weekly_schedule'];
    if (weeklySchedule == null || weeklySchedule is! List || weeklySchedule.isEmpty) {
      // 기본 빈 스케줄 반환
      return {
        'days': [
          {'name': 'Rest Day', 'exercises': []},
        ]
      };
    }
    
    // selectedWeek가 범위를 벗어나지 않도록 클램프
    final weekIndex = (selectedWeek - 1).clamp(0, weeklySchedule.length - 1);
    final weekData = weeklySchedule[weekIndex];
    
    if (weekData is Map<String, dynamic>) {
      return weekData;
    }
    
    // 잘못된 데이터 타입인 경우 기본값 반환
    return {
      'days': [
        {'name': 'Rest Day', 'exercises': []},
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.of(context).size.width >= 768;
    final totalWeeks = widget.program['duration_weeks'] as int;

    return ResponsiveScaffold(
      currentIndex: 3, // 루틴 프로그램 탭
      onNavTap: (index) {
        if (index != 3) {
          // 다른 탭으로 이동할 때는 뒤로가기 후 해당 탭으로 이동
          Navigator.of(context).pop();
          // 메인 네비게이션에서 탭 변경은 pop 후 자동으로 처리됨
        }
      },
      onAiTap: () {
        // TODO: AI 기능 구현
      },
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isWide ? 32 : 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1024),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 뒤로가기 버튼
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.cardBackgroundColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          l10n?.back ?? 'Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWide ? 18 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 프로그램 헤더
                    _buildProgramHeader(l10n, isWide),
                    const SizedBox(height: 24),

                    // 통계 카드
                    _buildStatsGrid(l10n, isWide),
                    const SizedBox(height: 24),

                    // 액션 버튼들
                    _buildActionButtons(l10n, isWide),
                    const SizedBox(height: 32),

                    // 장비 필요 섹션
                    _buildEquipmentSection(l10n, isWide),
                    const SizedBox(height: 32),

                    // 주간 스케줄 섹션
                    _buildWeeklyScheduleSection(l10n, isWide, totalWeeks),
                    
                    // 하단 여백 (네비게이션 바를 위한 공간)
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgramHeader(AppLocalizations? l10n, bool isWide) {
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.program['name'],
                        style: TextStyle(
                          fontSize: isWide ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n?.by ?? 'Created by'} ${widget.program['creator']}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: isWide ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: AppTheme.fatGraphColor, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      widget.program['rating'].toString(),
                      style: TextStyle(
                        color: Colors.amber[200],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.program['is_popular'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.fatGraphColor, AppTheme.fatGraphColor.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n?.popular ?? 'Popular',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.program['description'],
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: isWide ? 16 : 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<String>.from(widget.program['tags']).map((tag) {
                return _buildTagChip(tag, l10n);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag, AppLocalizations? l10n) {
    Color color = AppTheme.workoutIconColor;
    
    if (['beginner', 'intermediate', 'advanced'].contains(tag)) {
      color = tag == 'beginner' 
          ? AppTheme.nutritionIconColor 
          : tag == 'intermediate' 
              ? AppTheme.carbsGraphColor 
              : AppTheme.proteinGraphColor;
    } else if (['strength', 'powerlifting', 'bodybuilding'].contains(tag)) {
      color = tag == 'strength' 
          ? AppTheme.proteinGraphColor 
          : tag == 'powerlifting' 
              ? AppTheme.fatGraphColor 
              : AppTheme.carbsGraphColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getLocalizedTag(tag, l10n),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getLocalizedTag(String tag, AppLocalizations? l10n) {
    switch (tag) {
      case 'beginner':
        return l10n?.beginner ?? 'Beginner';
      case 'intermediate':
        return l10n?.intermediate ?? 'Intermediate';
      case 'advanced':
        return l10n?.advanced ?? 'Advanced';
      case 'strength':
        return l10n?.strength ?? 'Strength';
      case 'powerlifting':
        return l10n?.powerlifting ?? 'Powerlifting';
      case 'bodybuilding':
        return l10n?.bodybuilding ?? 'Bodybuilding';
      default:
        return tag;
    }
  }

  Widget _buildStatsGrid(AppLocalizations? l10n, bool isWide) {
    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isWide ? 1.2 : 2.0,
      mainAxisSpacing: isWide ? 12 : 16,
      crossAxisSpacing: isWide ? 12 : 16,
      children: [
        _buildStatCard(
          icon: Icons.calendar_month,
          iconColor: AppTheme.workoutIconColor,
          title: l10n?.duration ?? 'Duration',
          value: '${widget.program['duration_weeks']} ${l10n?.weeks ?? 'weeks'}',
          isWide: isWide,
        ),
        _buildStatCard(
          icon: Icons.fitness_center,
          iconColor: AppTheme.nutritionIconColor,
          title: l10n?.frequency ?? 'Frequency',
          value: '${widget.program['workouts_per_week']}x/${l10n?.week ?? 'week'}',
          isWide: isWide,
        ),
        _buildStatCard(
          icon: Icons.star,
          iconColor: AppTheme.fatGraphColor,
          title: l10n?.averageRating ?? 'Avg Rating',
          value: widget.program['rating'].toString(),
          isWide: isWide,
        ),
        _buildStatCard(
          icon: Icons.schedule,
          iconColor: AppTheme.carbsGraphColor,
          title: l10n?.avgWeeks ?? 'Avg Weeks',
          value: '${widget.program['duration_weeks']} ${l10n?.weeks ?? 'weeks'}',
          isWide: isWide,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isWide,
  }) {
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(isWide ? 16 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: isWide ? 24 : 24),
            SizedBox(height: isWide ? 6 : 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: isWide ? 12 : 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isWide ? 2 : 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isWide ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations? l10n, bool isWide) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.workoutIconColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: isWide ? 16 : 14),
              elevation: 0,
            ),
            onPressed: () async {
              final db = DatabaseHelper();
              final programId = widget.program['id'] as String;
              Map<String, dynamic>? up = await db.getActiveUserProgram(programId);
              if (up == null) {
                final uuid = const Uuid();
                up = {
                  'id': uuid.v4(),
                  'program_id': programId,
                  'current_week': 1,
                  'current_day': 1,
                  'started_at': DateTime.now().toIso8601String(),
                };
                await db.insertUserProgram(up);
              }

              if (!mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WorkoutSessionPage(
                    programId: programId,
                    showNavigation: true,
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n?.startProgram ?? 'Start Program',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isWide ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.nutritionIconColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: isWide ? 16 : 14, horizontal: isWide ? 24 : 20),
            elevation: 0,
          ),
          onPressed: () {
            // TODO: 저장 로직
          },
          child: Icon(Icons.bookmark, size: isWide ? 20 : 18),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.carbsGraphColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: isWide ? 16 : 14, horizontal: isWide ? 24 : 20),
            elevation: 0,
          ),
          onPressed: () {
            // TODO: 공유 로직
          },
          child: Icon(Icons.share, size: isWide ? 20 : 18),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(AppLocalizations? l10n, bool isWide) {
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.equipmentNeeded ?? 'Equipment Needed',
              style: TextStyle(
                color: Colors.white,
                fontSize: isWide ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<String>.from(widget.program['equipment_needed']).map((equipment) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Text(
                    equipment,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleSection(AppLocalizations? l10n, bool isWide, int totalWeeks) {
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.weeklySchedule ?? 'Weekly Schedule',
              style: TextStyle(
                color: Colors.white,
                fontSize: isWide ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Week 선택 페이지네이션
            _buildWeekPagination(totalWeeks, isWide),
            const SizedBox(height: 24),

            // 선택된 주차의 스케줄
            _buildWeekScheduleContent(l10n, isWide),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekPagination(int totalWeeks, bool isWide) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: weekPageStart > 0 ? _scrollLeft : null,
              icon: const Icon(Icons.chevron_left),
              style: IconButton.styleFrom(
                backgroundColor: weekPageStart > 0 ? Colors.grey[800] : Colors.transparent,
                foregroundColor: weekPageStart > 0 ? Colors.white : Colors.grey[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: currentWeeks.map((weekNum) {
                  final isSelected = selectedWeek == weekNum;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: isWide ? 64 : 56,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected 
                              ? AppTheme.workoutIconColor
                              : Colors.grey[800],
                          foregroundColor: isSelected 
                              ? Colors.white 
                              : Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: isSelected 
                                ? BorderSide.none 
                                : BorderSide(color: Colors.grey[700]!),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedWeek = weekNum;
                          });
                        },
                        child: Text(
                          'W$weekNum',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            IconButton(
              onPressed: (weekPageStart + weeksPerPage) < totalWeeks ? _scrollRight : null,
              icon: const Icon(Icons.chevron_right),
              style: IconButton.styleFrom(
                backgroundColor: (weekPageStart + weeksPerPage) < totalWeeks ? Colors.grey[800] : Colors.transparent,
                foregroundColor: (weekPageStart + weeksPerPage) < totalWeeks ? Colors.white : Colors.grey[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        if (totalPages > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPageIndex == index 
                      ? AppTheme.workoutIconColor 
                      : Colors.grey[600],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildWeekScheduleContent(AppLocalizations? l10n, bool isWide) {
    final weekSchedule = currentWeekSchedule;
    final days = List<Map<String, dynamic>>.from(weekSchedule['days'] ?? []);
    
    return Column(
      children: days.asMap().entries.map((entry) {
        final dayIndex = entry.key;
        final day = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(isWide ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n?.day ?? 'Day'} ${dayIndex + 1}: ${day['name'] ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWide ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (day['exercises'] != null) ...[
                    const SizedBox(height: 16),
                    ...List<Map<String, dynamic>>.from(day['exercises']).map((exercise) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(isWide ? 16 : 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise['name'] ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isWide ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${exercise['sets'] ?? 0} ${l10n?.sets ?? 'sets'}',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${exercise['reps'] ?? 0} ${l10n?.reps ?? 'reps'}',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (exercise['notes'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                exercise['notes'],
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}