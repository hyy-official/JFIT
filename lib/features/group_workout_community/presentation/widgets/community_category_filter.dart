import 'package:flutter/material.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_category.dart';

/// 커뮤니티 카테고리 필터 위젯
class CommunityCategoryFilter extends StatelessWidget {
  final List<PostCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final bool isVertical;

  const CommunityCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return _buildVerticalFilter(context);
    } else {
      return _buildHorizontalFilter(context);
    }
  }

  Widget _buildHorizontalFilter(BuildContext context) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip(
            context,
            null,
            '전체',
            Icons.apps,
          ),
          const SizedBox(width: 8),
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildCategoryChip(
              context,
              category.id,
              category.name,
              _getCategoryIcon(category.name),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVerticalFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildCategoryListTile(
          context,
          null,
          '전체',
          Icons.apps,
        ),
        
        ...categories.map((category) => _buildCategoryListTile(
          context,
          category.id,
          category.name,
          _getCategoryIcon(category.name),
        )),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String? categoryId,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedCategoryId == categoryId;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onCategoryChanged(categoryId);
        }
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected 
                ? colorScheme.onSecondaryContainer 
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.secondaryContainer,
      checkmarkColor: colorScheme.onSecondaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? colorScheme.onSecondaryContainer 
            : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected 
            ? colorScheme.secondary 
            : colorScheme.outline.withOpacity(0.2),
      ),
    );
  }

  Widget _buildCategoryListTile(
    BuildContext context,
    String? categoryId,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedCategoryId == categoryId;

    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 20,
        color: isSelected 
            ? colorScheme.primary 
            : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
      onTap: () => onCategoryChanged(categoryId),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case '운동':
      case 'workout':
        return Icons.fitness_center;
      case '식단':
      case 'diet':
        return Icons.restaurant;
      case '질문':
      case 'question':
        return Icons.help_outline;
      case '팁':
      case 'tip':
        return Icons.lightbulb_outline;
      case '자유':
      case 'free':
        return Icons.chat_bubble_outline;
      case '후기':
      case 'review':
        return Icons.rate_review;
      case '공지':
      case 'notice':
        return Icons.campaign;
      default:
        return Icons.article;
    }
  }
}