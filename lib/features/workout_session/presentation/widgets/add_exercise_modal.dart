import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/models/exercise.dart';
import 'package:jfit/services/exercise_search_service.dart';

class AddExerciseModal extends StatefulWidget {
  final Function(String exerciseName) onAdd;
  final VoidCallback? onCancel;

  const AddExerciseModal({
    super.key,
    required this.onAdd,
    this.onCancel,
  });

  @override
  State<AddExerciseModal> createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends State<AddExerciseModal> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customExerciseController = TextEditingController();
  final ExerciseSearchService _searchService = ExerciseSearchService();
  
  bool _isAdvancedFiltersExpanded = false;
  bool _isLoading = false;

  // Quick Filters
  List<String> _quickFilters = [];
  
  // Filter options (다중 선택 지원)
  Set<String> _selectedExerciseTypes = {};
  Set<String> _selectedMuscleGroups = {};
  Set<String> _selectedDifficultyLevels = {};
  Set<String> _selectedEquipment = {};

  // Exercise data from database
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];

  List<String> _equipmentOptions = [];

  List<String> _exerciseTypes = [];
  List<String> _muscleGroups = [];
  List<String> _difficultyLevels = [];

  @override
  void initState() {
    super.initState();
    _loadPopularExercises();
    _loadEquipmentOptions();
    _loadDifficultyOptions();
    _loadExerciseTypeOptions();
    _loadMuscleGroupOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customExerciseController.dispose();
    super.dispose();
  }

  /// 기본 운동 목록 로드
  Future<void> _loadPopularExercises() async {
    setState(() => _isLoading = true);
    
    try {
      final exercises = await _searchService.getPopularExercises(limit: 10);
      setState(() {
        _exercises = exercises;
        _filteredExercises = exercises;
      });
    } catch (e) {
      setState(() {
        _exercises = [];
        _filteredExercises = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 장비 필터 옵션 로드
  Future<void> _loadEquipmentOptions() async {
    try {
      final options = await _searchService.getEquipmentOptions();
      setState(() {
        _equipmentOptions = options.map((o) => o.ko).toList();
      });
    } catch (e) {
      setState(() {
        _equipmentOptions = [];
      });
    }
  }

  /// 운동 검색
  Future<void> _searchExercises() async {
    setState(() => _isLoading = true);
    
    try {
      final query = _searchController.text.trim();
      
      // 필터 준비 (다중 선택 지원)
      List<String>? equipmentFilters = _selectedEquipment.isNotEmpty ? _selectedEquipment.toList() : null;
      List<String>? difficultyFilters = _selectedDifficultyLevels.isNotEmpty ? _selectedDifficultyLevels.toList() : null;
      List<String>? typeFilters = _selectedExerciseTypes.isNotEmpty ? _selectedExerciseTypes.toList() : null;
      List<String>? muscleFilters = _selectedMuscleGroups.isNotEmpty ? _selectedMuscleGroups.toList() : null;

      final exercises = await _searchService.searchExercises(
        query: query,
        equipmentFilters: equipmentFilters,
        difficultyFilters: difficultyFilters,
        typeFilters: typeFilters,
        muscleFilters: muscleFilters,
        limit: 50,
        locale: Localizations.localeOf(context),
      );
      
      setState(() {
        _exercises = exercises;
        _filteredExercises = exercises;
      });
    } catch (e) {
      setState(() {
        _exercises = [];
        _filteredExercises = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addQuickFilter(String filter) {
    if (!_quickFilters.contains(filter)) {
      setState(() {
        _quickFilters.add(filter);
      });
    }
  }

  void _removeQuickFilter(String filter) {
    setState(() {
      _quickFilters.remove(filter);
    });
  }

  void _addExercise(String exerciseName) async {
    if (exerciseName.trim().isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      widget.onAdd(exerciseName.trim());
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Exercise> _getFilteredExercises() {
    return _filteredExercises;
  }

  /// 현재 로케일에 맞는 운동 제목 반환
  String _getLocalizedTitle(Exercise exercise) {
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';
    
    if (isKorean) {
      return exercise.titleKo.isNotEmpty ? exercise.titleKo : (exercise.titleEn ?? exercise.titleKo);
    } else {
      return exercise.titleEn?.isNotEmpty == true ? exercise.titleEn! : exercise.titleKo;
    }
  }

  /// 현재 로케일에 맞는 운동 설명 반환
  String _getLocalizedDescription(Exercise exercise) {
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';
    
    if (isKorean) {
      return exercise.descKo.isNotEmpty ? exercise.descKo : (exercise.descEn ?? '');
    } else {
      return exercise.descEn?.isNotEmpty == true ? exercise.descEn! : exercise.descKo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 700,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0a0a0a),
        borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchField(),
                        const SizedBox(height: 16),
                        _buildQuickFilters(),
                        const SizedBox(height: 16),
                        _buildAdvancedFilters(),
                        const SizedBox(height: 24),
                        _buildExerciseList(),
                        const SizedBox(height: 24),
                        _buildCreateCustomExercise(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF6366f1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
                 Text(
            AppLocalizations.of(context)?.exerciseAdd ?? 'Add Exercise',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        const Spacer(),
                IconButton(
                  onPressed: () {
                    widget.onCancel?.call();
                  },
          icon: const Icon(Icons.close, color: Color(0xFFa3a3a3), size: 24),
                ),
              ],
    );
  }

  Widget _buildSearchField() {
    return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF232323)),
              ),
              child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.exerciseSearchHint ?? 'Search exercises...',
          hintStyle: const TextStyle(color: Color(0xFF737373), fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF737373), size: 20),
                  border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) {
          // 실시간 검색 (500ms 디바운스)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              if (value.isEmpty) {
                _loadPopularExercises();
              } else {
                _searchExercises();
              }
            }
          });
        },
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.exerciseQuickFilters ?? 'Quick Filters',
          style: const TextStyle(
            color: Color(0xFFa3a3a3),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickFilters.map((filter) => _buildQuickFilterChip(filter)).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF232323)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            filter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeQuickFilter(filter),
            child: const Icon(
              Icons.close,
              color: Color(0xFF737373),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0f0f0f),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF232323)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isAdvancedFiltersExpanded = !_isAdvancedFiltersExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Color(0xFF6366f1), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)?.exerciseAdvancedFilters ?? 'Advanced Filters',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isAdvancedFiltersExpanded 
                        ? Icons.keyboard_arrow_up 
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF737373),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_isAdvancedFiltersExpanded) _buildFilterOptions(),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        children: [
          _buildFilterSection('운동 타입', _exerciseTypes, _selectedExerciseTypes),
          const SizedBox(height: 16),
          _buildFilterSection('근육 부위', _muscleGroups, _selectedMuscleGroups),
          const SizedBox(height: 16),
          _buildFilterSection('난이도', _difficultyLevels, _selectedDifficultyLevels),
          const SizedBox(height: 16),
          _buildFilterSection('장비', _equipmentOptions, _selectedEquipment),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, Set<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFa3a3a3),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedOptions.remove(option);
                  } else {
                    selectedOptions.add(option);
                  }
                });
                // 필터 변경 시 즉시 검색 실행
                _searchExercises();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366f1) : const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366f1) : const Color(0xFF232323),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF737373),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExerciseList() {
    final filteredExercises = _getFilteredExercises();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)?.exerciseList ?? 'Exercise List',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${filteredExercises.length} ${AppLocalizations.of(context)?.exerciseFound ?? 'found'}',
                style: const TextStyle(
                  color: Color(0xFF6366f1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300, // 고정 높이로 스크롤 가능하게 만듦
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6366f1),
                  ),
                )
              : filteredExercises.isEmpty
                  ? const Center(
                      child: Text(
                        '검색 결과가 없습니다',
                        style: TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredExercises.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        return _buildExerciseCard(exercise);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return GestureDetector(
      onTap: () {
        final title = _getLocalizedTitle(exercise);
        _addExercise(title);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0f0f0f),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF232323)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getLocalizedTitle(exercise),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_getLocalizedDescription(exercise).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _getLocalizedDescription(exercise),
                style: const TextStyle(
                  color: Color(0xFF737373),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildExerciseTag(exercise.equipmentKo),
                _buildExerciseTag(exercise.difficultyKo),
                if (exercise.primaryMusclesKo.isNotEmpty)
                  _buildExerciseTag(exercise.primaryMusclesKo.first),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTag(String tag) {
    Color tagColor;
    switch (tag) {
      // 운동 타입
      case '근력 운동':
        tagColor = const Color(0xFF3b82f6);
        break;
      case '유산소':
        tagColor = const Color(0xFF10b981);
        break;
      case '유연성':
        tagColor = const Color(0xFF8b5cf6);
        break;
      // 근육 부위
      case '가슴':
      case '어깨':
      case '팔':
      case '등':
      case '다리':
      case '엉덩이':
        tagColor = const Color(0xFFef4444);
        break;
      case '코어':
        tagColor = const Color(0xFFef4444);
        break;
      // 난이도
      case '초급':
        tagColor = const Color(0xFF22c55e);
        break;
      case '중급':
        tagColor = const Color(0xFFf59e0b);
        break;
      case '상급':
        tagColor = const Color(0xFFef4444);
        break;
      // 장비
      case '맨몸':
        tagColor = const Color(0xFF06b6d4);
        break;
      case '덤벨':
      case '바벨':
      case '머신':
        tagColor = const Color(0xFF6b7280);
        break;
      default:
        tagColor = const Color(0xFF6b7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCreateCustomExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.exerciseCreateCustom ?? 'Create Custom Exercise',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF232323)),
                ),
                child: TextField(
                  controller: _customExerciseController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.exerciseEnterName ?? 'Enter exercise name...',
                    hintStyle: const TextStyle(color: Color(0xFF737373), fontSize: 16),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  _addExercise(_customExerciseController.text);
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadDifficultyOptions() async {
    try {
      final options = await _searchService.getDifficultyOptions();
      setState(() {
        _difficultyLevels = options.map((o) => o.ko).toList();
      });
    } catch (e) {
      setState(() {
        _difficultyLevels = [];
      });
    }
  }

  Future<void> _loadExerciseTypeOptions() async {
    try {
      final options = await _searchService.getExerciseTypeOptions();
      var loaded = options.map((o) => o.ko).toList();
      if (loaded.isEmpty) {
        // DB 조회 실패 또는 결과 없으면 상수 리스트로 폴백
        loaded = ['근력 운동', '유산소', '유연성'];
      }
      setState(() {
        _exerciseTypes = loaded;
      });
    } catch (e) {
      setState(() {
        _exerciseTypes = ['근력 운동', '유산소', '유연성'];
      });
    }
  }

  Future<void> _loadMuscleGroupOptions() async {
    try {
      final options = await _searchService.getMuscleGroupOptions();
      var loaded = options.map((o) => o.ko).toList();
      if (loaded.isEmpty) {
        loaded = ['가슴', '어깨', '팔', '등', '다리', '엉덩이', '코어'];
      }
      setState(() {
        _muscleGroups = loaded;
      });
    } catch (e) {
      setState(() {
        _muscleGroups = ['가슴', '어깨', '팔', '등', '다리', '엉덩이', '코어'];
      });
    }
  }
} 