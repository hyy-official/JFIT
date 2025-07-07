import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jfit/core/theme/diet_sheet_theme.dart';
import 'diet_detail_form.dart';

class DietAddSheetContent extends StatefulWidget {
  final DateTime selectedDate;
  const DietAddSheetContent({super.key, required this.selectedDate});

  @override
  State<DietAddSheetContent> createState() => _DietAddSheetContentState();
}

class _DietAddSheetContentState extends State<DietAddSheetContent> {
  int _selectedTabIndex = 0;
  bool _hasTodayPhotos = false; // TODO: Supabase fetch

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DietSheetTheme.sheetBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: const BoxConstraints(maxWidth: 480),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildHandlebar(),
              _buildDateHeader(),
              _buildTabs(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _buildTabContent()),
                    const SizedBox(height: 16),
                    _buildActionGrid(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandlebar() {
    return Container(
      width: 48,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: DietSheetTheme.handlebarColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildDateHeader() {
    final formattedDate = DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(formattedDate, style: DietSheetTheme.dateHeaderStyle, textAlign: TextAlign.center),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: DietSheetTheme.tabContainerBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem('오늘의 사진', 0),
          _buildTabItem('북마크', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? DietSheetTheme.activeTabBackground : DietSheetTheme.inactiveTabBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: DietSheetTheme.tabTextStyle.copyWith(
              color: isActive ? DietSheetTheme.activeTabColor : DietSheetTheme.inactiveTabColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTabIndex == 0 && !_hasTodayPhotos) {
      return _buildEmptyState(
        icon: Icons.photo_library_outlined,
        title: '오늘 찍은 사진이 없어요',
        subtitle: '사진으로 기록하면 시간을 불러와서 편해요',
      );
    }
    if (_selectedTabIndex == 1) {
      return _buildEmptyState(
        icon: Icons.bookmark_border,
        title: '북마크한 식단이 없어요',
        subtitle: '자주 먹는 식단을 북마크하고 관리해보세요',
      );
    }
    return Container();
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: DietSheetTheme.secondaryTextColor),
        const SizedBox(height: 16),
        Text(title, style: DietSheetTheme.emptyMessageStyle),
        const SizedBox(height: 8),
        Text(subtitle, style: DietSheetTheme.subMessageStyle, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildActionGrid() {
    final actions = [
      {'text': '텍스트 기록', 'icon': Icons.edit_note_outlined, 'action': _onAddText},
      {'text': '사진 촬영', 'icon': Icons.camera_alt_outlined, 'action': _onTakePhoto},
      {'text': '앨범에서 찾기', 'icon': Icons.photo_outlined, 'action': _onPickFromGallery},
      {'text': '영양성분 기록', 'icon': Icons.pie_chart_outline, 'action': _onAddNutrition},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3.5,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return _buildActionButton(
          text: item['text'] as String,
          icon: item['icon'] as IconData,
          onTap: item['action'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildActionButton({required String text, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DietSheetTheme.buttonGridBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(text, style: DietSheetTheme.buttonTextStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder callbacks
  void _onAddText() {
    showDietDetailForm(context, widget.selectedDate);
  }

  void _onTakePhoto() {}
  void _onPickFromGallery() {}
  void _onAddNutrition() {}
} 