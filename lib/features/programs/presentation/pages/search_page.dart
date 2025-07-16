import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  
  // 더미 최근 검색어
  final List<String> recentSearches = [
    '헬스장 초보',
    'GM369',
    '파워리프팅',
    '직장인 루틴',
  ];
  
  // 더미 추천 검색어
  final List<String> suggestedSearches = [
    '벤치프레스',
    '스쿼트',
    '데드리프트',
    '근비대',
    '다이어트',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: context.colors.textMuted),
              hintText: '루틴 또는 코치 이름을 검색하세요',
              hintStyle: TextStyle(color: context.colors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (v) => setState(() => searchText = v),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchText.isEmpty) ...[
              // 최근 검색어
              if (recentSearches.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('최근 검색어', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () {},
                      child: Text('전체 삭제', style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...recentSearches.map((search) => ListTile(
                  leading: Icon(Icons.history, color: context.colors.textMuted),
                  title: Text(search, style: TextStyle(color: context.colors.textPrimary)),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: context.colors.textMuted),
                    onPressed: () {},
                  ),
                  onTap: () {
                    _searchController.text = search;
                    setState(() => searchText = search);
                  },
                )),
                const SizedBox(height: 24),
              ],
              // 추천 검색어
              Text('추천 검색어', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestedSearches.map((search) => GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    setState(() => searchText = search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.outline),
                    ),
                    child: Text(search, style: TextStyle(color: context.colors.textSecondary)),
                  ),
                )).toList(),
              ),
            ] else ...[
              // 검색 결과 (더미)
              Text('검색 결과', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 3, // 더미 결과 개수
                  itemBuilder: (context, index) => ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: context.colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.fitness_center, color: context.colors.textMuted),
                    ),
                    title: Text('검색 결과 ${index + 1}', style: TextStyle(color: context.colors.textPrimary)),
                    subtitle: Text('$searchText 관련 프로그램', style: TextStyle(color: context.colors.textSecondary)),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 