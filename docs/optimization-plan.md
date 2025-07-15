# 🚀 Program Detail Sheet 최적화 및 개선 계획

## 📊 현재 상태 분석

### ✅ 완료된 리팩토링
- [x] 974줄 → 7개 파일로 분리
- [x] 컴포넌트 기반 아키텍처 적용
- [x] Provider 패턴으로 상태 관리 분리
- [x] 재사용 가능한 위젯 컴포넌트 생성
- [x] "Day N 시작하기" 버튼 활성화 문제 해결

## 🎯 **1단계: 상태 관리 개선 (BLoC 패턴)**

### 목표
- Provider + ChangeNotifier → BLoC 패턴으로 전환
- 더 예측 가능하고 테스트하기 쉬운 상태 관리

### 구현 계획
```dart
// 새로운 BLoC 구조
lib/features/records/presentation/bloc/program_detail/
├── program_detail_bloc.dart
├── program_detail_event.dart
├── program_detail_state.dart
└── program_detail_bloc_test.dart
```

### 주요 이벤트들
```dart
abstract class ProgramDetailEvent extends Equatable {}

class LoadProgramDetail extends ProgramDetailEvent {
  final String userProgramId;
}

class SelectWeek extends ProgramDetailEvent {
  final int week;
}

class SelectDay extends ProgramDetailEvent {
  final int dayIndex;
  final List<UserProgramDayModel> weekDays;
}

class SetNextWorkoutDay extends ProgramDetailEvent {
  final Map<String, dynamic> programDetails;
  final List<UserProgramDayModel> days;
}
```

### 예상 효과
- 🧪 **테스트 용이성**: 각 이벤트별 단위 테스트 가능
- 🔄 **상태 추적**: 모든 상태 변화가 명확하게 추적됨
- 🐛 **디버깅 개선**: BLoC Observer로 모든 상태 변화 로깅

---

## 🎨 **2단계: 애니메이션 및 UX 개선**

### 2.1 페이드 인/아웃 애니메이션
```dart
// 컴포넌트 등장 애니메이션
class AnimatedProgramHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: ProgramHeader(...),
          ),
        );
      },
    );
  }
}
```

### 2.2 주차/일차 선택 애니메이션
```dart
// 선택 시 부드러운 전환 효과
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  decoration: BoxDecoration(
    gradient: isSelected ? AppTheme.accentGradient : null,
    // ... 기타 스타일
  ),
)
```

### 2.3 운동 목록 스태거드 애니메이션
```dart
// 운동 항목들이 순차적으로 나타나는 효과
class StaggeredExerciseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: ExerciseListItem(...),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 2.4 버튼 상호작용 애니메이션
```dart
// 버튼 눌림 효과 및 로딩 애니메이션
class AnimatedStartButton extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // ... 버튼 스타일
      ),
    );
  }
}
```

---

## ⚡ **3단계: 성능 최적화**

### 3.1 메모이제이션 적용
```dart
// 불필요한 리빌드 방지
class MemoizedExerciseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return useMemoized(
      () => ExerciseList(exercisesFuture: exercisesFuture),
      [exercisesFuture.hashCode],
    );
  }
}
```

### 3.2 이미지 및 데이터 캐싱 개선
```dart
// 향상된 캐시 시스템
class EnhancedCacheManager {
  static final _instance = EnhancedCacheManager._internal();
  factory EnhancedCacheManager() => _instance;
  
  final Map<String, CachedData> _cache = {};
  final Duration _cacheExpiry = const Duration(minutes: 30);
  
  Future<T?> get<T>(String key) async {
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) {
      return cached.data as T;
    }
    return null;
  }
  
  void set<T>(String key, T data) {
    _cache[key] = CachedData(data, DateTime.now().add(_cacheExpiry));
  }
}
```

### 3.3 지연 로딩 및 페이지네이션
```dart
// 대량 데이터 처리 시 지연 로딩
class LazyLoadedExerciseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LazyLoadScrollView(
      onEndOfPage: () => _loadMoreExercises(),
      child: ListView.builder(...),
    );
  }
}
```

---

## 🧪 **4단계: 테스트 전략**

### 4.1 단위 테스트
```dart
// BLoC 테스트
group('ProgramDetailBloc', () {
  test('should emit correct states when SelectWeek is added', () {
    // Given
    final bloc = ProgramDetailBloc();
    
    // When
    bloc.add(SelectWeek(2));
    
    // Then
    expectLater(
      bloc.stream,
      emitsInOrder([
        ProgramDetailState(selectedWeek: 2),
      ]),
    );
  });
});
```

### 4.2 위젯 테스트
```dart
// 컴포넌트 테스트
group('ProgramHeader', () {
  testWidgets('should display program name and progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProgramHeader(
          programName: 'Test Program',
          progressPercent: 75.0,
        ),
      ),
    );
    
    expect(find.text('Test Program'), findsOneWidget);
    expect(find.text('75.0% 진행 중'), findsOneWidget);
  });
});
```

### 4.3 통합 테스트
```dart
// 전체 플로우 테스트
group('Program Detail Flow', () {
  testWidgets('should navigate through weeks and days correctly', (tester) async {
    // 전체 사용자 플로우 테스트
  });
});
```

---

## 🔧 **5단계: 접근성 개선**

### 5.1 스크린 리더 지원
```dart
Semantics(
  label: '${week}주차 선택',
  hint: '탭하여 ${week}주차로 이동',
  child: WeekTab(...),
)
```

### 5.2 키보드 네비게이션
```dart
Focus(
  onKeyEvent: (node, event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          _selectPreviousWeek();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowRight:
          _selectNextWeek();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  },
  child: WeekNavigation(...),
)
```

---

## 📱 **6단계: 반응형 디자인 개선**

### 6.1 적응형 레이아웃
```dart
class ResponsiveProgramDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return DesktopProgramDetailLayout();
        } else if (constraints.maxWidth > 600) {
          return TabletProgramDetailLayout();
        } else {
          return MobileProgramDetailLayout();
        }
      },
    );
  }
}
```

### 6.2 다크 모드 지원 개선
```dart
// 테마별 최적화된 색상 및 애니메이션
class ThemeAwareProgramHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
      ),
      child: ...,
    );
  }
}
```

---

## 🚀 **구현 우선순위**

### Phase 1 (즉시 구현)
1. ✅ 버튼 활성화 문제 해결 (완료)
2. 🎨 기본 애니메이션 추가 (페이드 인/아웃)
3. ⚡ 메모이제이션 적용

### Phase 2 (1주 내)
1. 🔄 BLoC 패턴으로 상태 관리 전환
2. 🧪 단위 테스트 작성
3. 🎨 고급 애니메이션 추가

### Phase 3 (2주 내)
1. ⚡ 성능 최적화 (캐싱, 지연 로딩)
2. 🔧 접근성 개선
3. 📱 반응형 디자인 개선

---

## 📊 **성공 지표**

### 성능 지표
- 🚀 **초기 로딩 시간**: < 500ms
- 🔄 **상태 전환 시간**: < 100ms
- 💾 **메모리 사용량**: 현재 대비 20% 감소

### 사용자 경험 지표
- 😊 **애니메이션 부드러움**: 60fps 유지
- 🎯 **접근성 점수**: WCAG 2.1 AA 준수
- 📱 **반응형 지원**: 모든 화면 크기에서 최적화

### 개발자 경험 지표
- 🧪 **테스트 커버리지**: > 80%
- 🐛 **버그 발생률**: 현재 대비 50% 감소
- 🔧 **유지보수성**: 새 기능 추가 시간 단축