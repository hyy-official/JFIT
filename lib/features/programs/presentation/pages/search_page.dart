import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';

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
      backgroundColor: AppTheme.programBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: AppTheme.programCardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.white38),
              hintText: '루틴 또는 코치 이름을 검색하세요',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                    const Text('최근 검색어', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('전체 삭제', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...recentSearches.map((search) => ListTile(
                  leading: const Icon(Icons.history, color: Colors.white38),
                  title: Text(search, style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white38),
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
              const Text('추천 검색어', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                      color: AppTheme.programCardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(search, style: const TextStyle(color: Colors.white70)),
                  ),
                )).toList(),
              ),
            ] else ...[
              // 검색 결과 (더미)
              const Text('검색 결과', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 3, // 더미 결과 개수
                  itemBuilder: (context, index) => ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.white24),
                    ),
                    title: Text('검색 결과 ${index + 1}', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('$searchText 관련 프로그램', style: const TextStyle(color: Colors.white70)),
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