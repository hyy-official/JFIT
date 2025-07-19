# 테스트 파일 수정 우선순위 목록

## 우선순위 1: 즉시 수정 필요 (컴파일 에러 해결)

### 1. BLoC 테스트 파일들
```
test/features/group_workout_community/presentation/bloc/group/group_bloc_test.dart
- 문제: JoinGroup, LoadGroupMembers 이벤트 생성자 불일치
- 문제: GroupErrorState.message 프로퍼티 접근 오류
- 문제: ValidationFailure, PermissionFailure 타입 누락
- 예상 수정 시간: 2시간

test/features/group_workout_community/presentation/bloc/ranking/ranking_bloc_test.dart  
- 문제: RankingPeriodRequest 객체 미사용
- 문제: BodyPart enum 대신 String 사용
- 문제: 상태 프로퍼티 접근 오류 (scores, userId, period 등)
- 예상 수정 시간: 3시간
```

### 2. Repository 테스트 파일들
```
test/features/group_workout_community/data/repositories/community_repository_impl_test.dart
- 문제: PostSearchRequest 객체 미사용
- 문제: updatePost 메서드 매개변수 불일치 (userId 누락)
- 예상 수정 시간: 1.5시간

test/features/group_workout_community/data/repositories/group_repository_impl_test.dart
- 문제: 메서드 시그니처 불일치
- 문제: Request 객체 사용 패턴 미적용
- 예상 수정 시간: 1.5시간

test/features/group_workout_community/data/repositories/ranking_repository_impl_test.dart
- 문제: RankingPeriodRequest, CalculateScoreRequest 객체 미사용
- 문제: 메서드 매개변수 구조 불일치
- 예상 수정 시간: 2시간
```

## 우선순위 2: 중요 (기능 검증 개선)

### 3. 추가 BLoC 테스트 파일들
```
test/features/group_workout_community/presentation/bloc/community/community_bloc_test.dart
- 문제: PostSearchRequest 사용 패턴 적용 필요
- 예상 수정 시간: 1시간

test/features/group_workout_community/presentation/bloc/post_interaction/post_interaction_bloc_test.dart
- 문제: 상태 및 이벤트 구조 확인 필요
- 예상 수정 시간: 1시간

test/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc_test.dart
- 문제: 이벤트 및 상태 구조 검증 필요
- 예상 수정 시간: 1시간
```

## 우선순위 3: 일반 (도메인 로직 검증)

### 4. Entity 테스트 파일들
```
test/features/group_workout_community/domain/entities/workout_group_test.dart
- 문제: copyWith 메서드 동작 확인 필요
- 예상 수정 시간: 30분

test/features/group_workout_community/domain/entities/user_workout_score_test.dart
- 문제: BodyPart enum 사용 확인 필요
- 예상 수정 시간: 30분

test/features/group_workout_community/domain/entities/community_post_test.dart
- 문제: fromJson/toJson 메서드 검증 필요
- 예상 수정 시간: 30분

test/features/group_workout_community/domain/entities/group_member_test.dart
- 문제: 엔티티 구조 검증 필요
- 예상 수정 시간: 30분
```

## 우선순위 4: 낮음 (UI 및 통합 테스트)

### 5. Widget 테스트 파일들
```
test/features/group_workout_community/presentation/widgets/group_card_test.dart
test/features/group_workout_community/presentation/widgets/community_post_card_test.dart
test/features/group_workout_community/presentation/widgets/ranking_leaderboard_widget_test.dart
test/features/group_workout_community/presentation/widgets/chat_message_bubble_test.dart
test/features/group_workout_community/presentation/widgets/group_search_bar_test.dart
- 문제: 실제 위젯 구현과 일치 여부 확인 필요
- 예상 수정 시간: 각 30분씩 총 2.5시간
```

### 6. 통합 테스트 파일들
```
test/integration/group_workout_community_integration_test.dart
test/integration/group_workout_community_supabase_integration_test.dart
test/integration/group_workout_community_realtime_integration_test.dart
- 문제: End-to-end 시나리오 검증 필요
- 예상 수정 시간: 각 1시간씩 총 3시간
```

## 수정 순서 권장사항

### 1일차: 기본 환경 설정 (4시간)
1. ValidationFailure, PermissionFailure 타입 추가/대체
2. group_bloc_test.dart 수정 (이벤트 생성자, 상태 접근)
3. 기본 컴파일 에러 해결

### 2일차: Repository 테스트 수정 (5시간)  
1. ranking_bloc_test.dart 수정 (Request 객체, BodyPart enum)
2. community_repository_impl_test.dart 수정
3. group_repository_impl_test.dart 수정
4. ranking_repository_impl_test.dart 수정

### 3일차: 추가 BLoC 및 Entity 테스트 (4시간)
1. 나머지 BLoC 테스트 파일들 수정
2. Entity 테스트 파일들 검증 및 수정
3. 전체 테스트 실행 및 검증

### 4일차: Widget 및 통합 테스트 (4시간)
1. Widget 테스트 파일들 검증
2. 통합 테스트 파일들 검증
3. 최종 테스트 스위트 실행 및 안정성 확인

## 총 예상 작업 시간: 17시간

## 성공 지표
- [ ] 모든 우선순위 1 파일들이 컴파일 에러 없이 실행됨
- [ ] 우선순위 2 파일들의 기능 검증이 정확히 수행됨
- [ ] 전체 테스트 스위트가 안정적으로 실행됨
- [ ] 테스트 커버리지가 유지되거나 향상됨