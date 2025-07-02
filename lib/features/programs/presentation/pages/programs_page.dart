import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/database/database_helper.dart';
import 'package:jfit/features/programs/presentation/widgets/program_card.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/extensions/context_extensions.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _allPrograms = [];
  List<Map<String, dynamic>> _filteredPrograms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final programs = await _dbHelper.getWorkoutPrograms();
      setState(() {
        _allPrograms = programs;
        _filteredPrograms = programs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading programs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredPrograms = _allPrograms.where((program) {
        // 검색 텍스트 필터
        if (searchText.isNotEmpty) {
          final name = program['name']?.toString().toLowerCase() ?? '';
          final creator = program['creator']?.toString().toLowerCase() ?? '';
          final description = program['description']?.toString().toLowerCase() ?? '';
          final searchLower = searchText.toLowerCase();
          
          if (!name.contains(searchLower) && 
              !creator.contains(searchLower) && 
              !description.contains(searchLower)) {
            return false;
          }
        }

        // 난이도 필터
        if (selectedLevel != 'all' && program['difficulty_level'] != selectedLevel) {
          return false;
        }

        // 타입 필터
        if (selectedType != 'all' && program['program_type'] != selectedType) {
          return false;
        }

        // 기간 필터
        if (selectedDuration != 'all') {
          final duration = program['duration_weeks']?.toString() ?? '';
          if (duration != selectedDuration) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  // l10n 변환 함수
  String getLevelLabel(String level, AppLocalizations? l10n) {
    switch (level) {
      case 'beginner':
        return l10n?.beginner ?? 'Beginner';
      case 'intermediate':
        return l10n?.intermediate ?? 'Intermediate';
      case 'advanced':
        return l10n?.advanced ?? 'Advanced';
      default:
        return l10n?.allLevels ?? 'All Levels';
    }
  }
  String getTypeLabel(String type, AppLocalizations? l10n) {
    switch (type) {
      case 'strength':
        return l10n?.strength ?? 'Strength';
      case 'powerlifting':
        return l10n?.powerlifting ?? 'Powerlifting';
      case 'bodybuilding':
        return l10n?.bodybuilding ?? 'Bodybuilding';
      case 'hypertrophy':
        return l10n?.bodybuilding ?? 'Hypertrophy';
      default:
        return l10n?.allTypes ?? 'All Types';
    }
  }

  List<Map<String, String>> get levels => [
    {'value': 'all', 'label': l10n?.allLevels ?? 'All Levels'},
    {'value': 'beginner', 'label': l10n?.beginner ?? 'Beginner'},
    {'value': 'intermediate', 'label': l10n?.intermediate ?? 'Intermediate'},
    {'value': 'advanced', 'label': l10n?.advanced ?? 'Advanced'},
  ];
  List<Map<String, String>> get types => [
    {'value': 'all', 'label': l10n?.allTypes ?? 'All Types'},
    {'value': 'strength', 'label': l10n?.strength ?? 'Strength'},
    {'value': 'powerlifting', 'label': l10n?.powerlifting ?? 'Powerlifting'},
    {'value': 'bodybuilding', 'label': l10n?.bodybuilding ?? 'Bodybuilding'},
    {'value': 'hypertrophy', 'label': l10n?.bodybuilding ?? 'Hypertrophy'},
  ];
  List<Map<String, String>> get durations => [
    {'value': 'all', 'label': l10n?.allDurations ?? 'All Durations'},
    {'value': '8', 'label': '8 ${l10n?.weeks ?? 'weeks'}'},
    {'value': '12', 'label': '12 ${l10n?.weeks ?? 'weeks'}'},
    {'value': '16', 'label': '16 ${l10n?.weeks ?? 'weeks'}'},
  ];

  String selectedLevel = 'all';
  String selectedType = 'all';
  String selectedDuration = 'all';
  String searchText = '';

  AppLocalizations? get l10n => AppLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (_isLoading) {
      return Container(
        color: context.colors.background,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 통계 계산
    final totalPrograms = _allPrograms.length;
    final popularPrograms = _allPrograms.where((p) => (p['is_popular'] ?? 0) == 1).length;
    final avgRating = _allPrograms.isNotEmpty 
        ? _allPrograms.map((p) => (p['rating'] ?? 0.0) as double).reduce((a, b) => a + b) / _allPrograms.length 
        : 0.0;
    final avgWeeks = _allPrograms.isNotEmpty 
        ? _allPrograms.map((p) => (p['duration_weeks'] ?? 0) as int).reduce((a, b) => a + b) / _allPrograms.length 
        : 0.0;

    final stats = [
      {
        'icon': Icons.fitness_center,
        'label': l10n?.totalPrograms ?? 'Total Programs',
        'value': totalPrograms,
        'color': AppTheme.workoutIconColor,
      },
      {
        'icon': Icons.star,
        'label': l10n?.popularPrograms ?? 'Popular Programs',
        'value': popularPrograms,
        'color': AppTheme.nutritionIconColor,
      },
      {
        'icon': Icons.thumb_up,
        'label': l10n?.averageRating ?? 'Average Rating',
        'value': avgRating.toStringAsFixed(1),
        'color': AppTheme.proteinGraphColor,
      },
      {
        'icon': Icons.schedule,
        'label': l10n?.avgWeeks ?? 'Avg Weeks',
        'value': avgWeeks.toStringAsFixed(0),
        'color': AppTheme.carbsGraphColor,
      },
    ];

    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      color: context.colors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Text(
              l10n?.workoutPrograms ?? 'Workout Programs',
              style: context.texts.headlineLarge?.copyWith(fontSize: isWide ? 32 : 28, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              l10n?.workoutProgramsDesc ?? 'Discover and follow professional workout programs designed by experts.',
              style: context.texts.bodyMedium?.copyWith(fontSize: isWide ? 16 : 15, color: AppTheme.textSub),
            ),
            SizedBox(height: 32),
            // 통계 카드
            isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: stats.map((s) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _StatCard(
                          icon: s['icon'] as IconData,
                          label: s['label'] as String,
                          value: s['value'].toString(),
                          color: s['color'] as Color,
                        ),
                      ),
                    )).toList(),
                  )
                : Column(
                    children: stats.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StatCard(
                        icon: s['icon'] as IconData,
                        label: s['label'] as String,
                        value: s['value'].toString(),
                        color: s['color'] as Color,
                      ),
                    )).toList(),
                  ),
            SizedBox(height: 24),
            // 검색/필터 바
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l10n?.searchProgramsHint ?? 'Search programs, creators, or keywords...',
                      hintStyle: context.texts.bodySmall?.copyWith(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: context.colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    style: context.texts.bodyMedium?.copyWith(color: Colors.white),
                    onChanged: (v) {
                      setState(() => searchText = v);
                      _applyFilters();
                    },
                  ),
                ),
                SizedBox(width: 12),
                _FilterButton(
                  label: levels.firstWhere((e) => e['value'] == selectedLevel)['label']!,
                  options: levels.map((e) => e['label']!).toList(),
                  onSelected: (val) {
                    final found = levels.firstWhere((e) => e['label'] == val);
                    setState(() => selectedLevel = found['value']!);
                    _applyFilters();
                  },
                ),
                SizedBox(width: 8),
                _FilterButton(
                  label: types.firstWhere((e) => e['value'] == selectedType)['label']!,
                  options: types.map((e) => e['label']!).toList(),
                  onSelected: (val) {
                    final found = types.firstWhere((e) => e['label'] == val);
                    setState(() => selectedType = found['value']!);
                    _applyFilters();
                  },
                ),
                SizedBox(width: 8),
                _FilterButton(
                  label: durations.firstWhere((e) => e['value'] == selectedDuration)['label']!,
                  options: durations.map((e) => e['label']!).toList(),
                  onSelected: (val) {
                    final found = durations.firstWhere((e) => e['label'] == val);
                    setState(() => selectedDuration = found['value']!);
                    _applyFilters();
                  },
                ),
              ],
            ),
            SizedBox(height: 24),
            // 프로그램 카드 리스트
            _filteredPrograms.isEmpty
                ? Center(child: Text(l10n?.noProgramsFound ?? 'No programs found.', style: TextStyle(color: Colors.grey[500], fontSize: 16)))
                : GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 3 : 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWide ? 1.05 : 0.95,
                    ),
                    itemCount: _filteredPrograms.length,
                    itemBuilder: (context, idx) => ProgramCard(
                      program: _filteredPrograms[idx],
                      getLevelLabel: getLevelLabel,
                      getTypeLabel: getTypeLabel,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Card(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 16 : 24, 
          vertical: isWide ? 16 : 20,
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(isWide ? 8 : 12),
              child: Icon(icon, color: color, size: isWide ? 20 : 28),
            ),
            SizedBox(width: isWide ? 12 : 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value, 
                    style: TextStyle(
                      fontSize: isWide ? 18 : 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    label, 
                    style: context.texts.bodySmall?.copyWith(fontSize: isWide ? 12 : 15, color: AppTheme.textSub),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;
  const _FilterButton({required this.label, required this.options, required this.onSelected});
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: label,
      color: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: onSelected,
      itemBuilder: (context) => options.map((opt) => PopupMenuItem<String>(
        value: opt,
        child: Text(opt, style: context.texts.bodyMedium?.copyWith(color: Colors.white)),
      )).toList(),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: context.colors.surface,
          foregroundColor: Colors.white,
          side: BorderSide(color: AppTheme.surface2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        onPressed: null,
        child: Row(
          children: [
            Text(label, style: TextStyle(color: Colors.white, fontSize: 14)),
            Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
} 