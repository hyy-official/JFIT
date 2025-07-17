# BLOC 리팩토링 마이그레이션 가이드

## 개요

이 문서는 JFit 앱의 단일 RecordBloc을 기능별로 분리한 BLOC 리팩토링 프로젝트의 마이그레이션 가이드입니다. 이 리팩토링을 통해 코드의 가독성, 유지보수성, 그리고 성능이 크게 향상되었습니다.

## 마이그레이션 완료 상태

### ✅ 완료된 작업

1. **새로운 BLOC 구조 생성**
   - MealBloc: 식사 기록 관리
   - WorkoutProgramBloc: 운동 프로그램 관리
   - WorkoutSessionBloc: 운동 세션 관리
   - DailySummaryBloc: 일일 요약 관리
   - ExerciseBloc: 운동 정보 검색

2. **BLOC 간 통신 시스템**
   - BlocEventBus를 통한 BLOC 간 통신
   - 데이터 일관성 유지를 위한 자동 업데이트

3. **UI 컴포넌트 마이그레이션**
   - 모든 UI 컴포넌트가 새로운 BLOC 구조 사용
   - 대시보드 및 메인 네비게이션 업데이트

4. **의존성 주입 업데이트**
   - GetIt을 통한 새로운 BLOC 및 Repository 등록
   - 기존 RecordBloc 관련 설정 제거

5. **성능 최적화**
   - 메모리 사용량 최적화
   - 불필요한 리빌드 방지
   - 캐싱 전략 적용

6. **테스트 작성**
   - 각 BLOC별 단위 테스트
   - 통합 테스트 및 성능 테스트

7. **코드 정리**
   - 기존 RecordBloc 관련 파일 제거
   - 사용하지 않는 import 정리

## 새로운 BLOC 구조

### 1. MealBloc
**위치**: `lib/features/meal/bloc/`
**책임**: 식사 기록의 CRUD 작업

```dart
// 사용 예시
context.read<MealBloc>().add(LoadMealRecords(userId: userId, date: DateTime.now()));
context.read<MealBloc>().add(AddMealRecord(mealRecord: newRecord));
```

### 2. WorkoutProgramBloc
**위치**: `lib/features/workout_program/bloc/`
**책임**: 운동 프로그램 생성, 조회, 진행 상황 관리

```dart
// 사용 예시
context.read<WorkoutProgramBloc>().add(LoadUserPrograms(userId: userId));
context.read<WorkoutProgramBloc>().add(UpdateProgramProgress(userProgramId: id, week: 2, day: 3));
```

### 3. WorkoutSessionBloc
**위치**: `lib/features/workout_session/bloc/`
**책임**: 실제 운동 세션의 시작, 진행, 완료

```dart
// 사용 예시
context.read<WorkoutSessionBloc>().add(CreateWorkoutSession(sessionData));
context.read<WorkoutSessionBloc>().add(LogWorkoutSet(setData));
context.read<WorkoutSessionBloc>().add(CompleteWorkoutSession(sessionId));
```

### 4. DailySummaryBloc
**위치**: `lib/features/daily_summary/bloc/`
**책임**: 일일 요약 데이터 계산 및 관리

```dart
// 사용 예시
context.read<DailySummaryBloc>().add(LoadDailySummary(userId: userId, date: date));
context.read<DailySummaryBloc>().add(RefreshDailySummary(userId: userId, date: date));
```

### 5. ExerciseBloc
**위치**: `lib/features/exercise/bloc/`
**책임**: 운동 정보 검색 및 상세 정보 조회

```dart
// 사용 예시
context.read<ExerciseBloc>().add(SearchExercises(query: "push up"));
context.read<ExerciseBloc>().add(LoadExerciseDetails(exerciseId: id));
```

## BLOC 간 통신

### BlocEventBus 사용법

```dart
// 이벤트 발행
BlocEventBus().emit(MealRecordChangedEvent(userId, date));

// 이벤트 구독
BlocEventBus().stream.listen((event) {
  if (event is MealRecordChangedEvent) {
    // DailySummaryBloc 업데이트
    add(RefreshDailySummary(userId: event.userId, date: event.date));
  }
});
```

## 의존성 주입 설정

### GetIt 설정 (injection_container.dart)

```dart
void setupDependencies() {
  // Repositories
  getIt.registerLazySingleton<MealRepository>(() => MealRepositoryImpl(supabaseClient: getIt()));
  getIt.registerLazySingleton<WorkoutProgramRepository>(() => WorkoutProgramRepositoryImpl(supabaseClient: getIt()));
  // ... 기타 Repository들

  // BLoCs
  getIt.registerFactory<MealBloc>(() => MealBloc(mealRepository: getIt()));
  getIt.registerFactory<WorkoutProgramBloc>(() => WorkoutProgramBloc(workoutProgramRepository: getIt()));
  // ... 기타 BLOC들
}
```

## UI 컴포넌트 사용법

### BlocProvider 설정

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<MealBloc>(create: (context) => GetIt.instance<MealBloc>()),
    BlocProvider<DailySummaryBloc>(create: (context) => GetIt.instance<DailySummaryBloc>()),
  ],
  child: MyWidget(),
)
```

### BlocBuilder 사용

```dart
BlocBuilder<MealBloc, MealState>(
  builder: (context, state) {
    if (state is MealLoading) {
      return CircularProgressIndicator();
    } else if (state is MealRecordsLoaded) {
      return MealList(meals: state.meals);
    } else if (state is MealError) {
      return ErrorWidget(error: state.message);
    }
    return Container();
  },
)
```

## 성능 최적화 가이드

### 1. 메모리 최적화
- 각 BLOC은 독립적인 생명주기를 가짐
- 불필요한 BLOC 인스턴스 생성 방지
- 적절한 dispose 처리

### 2. 상태 관리 최적화
- Equatable을 통한 불필요한 리빌드 방지
- 상태 변화 최소화
- 선택적 리빌드 사용

### 3. 캐싱 전략
- Repository 레벨에서의 데이터 캐싱
- 네트워크 요청 최적화
- 메모리 캐시 관리

## 테스트 가이드

### 단위 테스트 예시

```dart
group('MealBloc Tests', () {
  late MealBloc mealBloc;
  late MockMealRepository mockRepository;

  setUp(() {
    mockRepository = MockMealRepository();
    mealBloc = MealBloc(mealRepository: mockRepository);
  });

  blocTest<MealBloc, MealState>(
    'emits [MealLoading, MealRecordsLoaded] when LoadMealRecords is added',
    build: () => mealBloc,
    act: (bloc) => bloc.add(LoadMealRecords(userId: 'test', date: DateTime.now())),
    expect: () => [MealLoading(), MealRecordsLoaded(meals: [])],
  );
});
```

## 마이그레이션 시 주의사항

### 1. 기존 코드 호환성
- 기존 UI 컴포넌트는 점진적으로 마이그레이션
- 데이터 구조 변경 시 하위 호환성 고려
- 테스트를 통한 기능 검증 필수

### 2. 성능 고려사항
- BLOC 인스턴스 생성 비용 고려
- 메모리 사용량 모니터링
- 네트워크 요청 최적화

### 3. 에러 처리
- 각 BLOC별 에러 처리 전략 수립
- 사용자 친화적 에러 메시지 제공
- 에러 복구 메커니즘 구현

## 향후 개선 사항

### 1. 추가 최적화
- 더 세밀한 상태 관리
- 추가적인 캐싱 전략
- 성능 모니터링 강화

### 2. 기능 확장
- 새로운 기능 추가 시 BLOC 패턴 적용
- 더 복잡한 BLOC 간 통신 패턴
- 오프라인 지원 강화

### 3. 코드 품질
- 더 많은 테스트 케이스 추가
- 코드 리뷰 프로세스 강화
- 문서화 개선

## 문제 해결

### 자주 발생하는 문제들

1. **BLOC 인스턴스를 찾을 수 없음**
   - BlocProvider가 올바르게 설정되었는지 확인
   - GetIt 의존성 주입이 올바르게 등록되었는지 확인

2. **상태가 업데이트되지 않음**
   - Equatable이 올바르게 구현되었는지 확인
   - 상태 객체가 새로운 인스턴스인지 확인

3. **메모리 누수**
   - BLOC dispose가 올바르게 호출되는지 확인
   - StreamSubscription이 올바르게 취소되는지 확인

## 결론

이번 BLOC 리팩토링을 통해 JFit 앱의 아키텍처가 크게 개선되었습니다. 각 BLOC의 책임이 명확해지고, 코드의 가독성과 유지보수성이 향상되었으며, 성능도 최적화되었습니다. 

새로운 기능을 추가할 때는 이 가이드를 참고하여 일관된 패턴을 유지하시기 바랍니다.