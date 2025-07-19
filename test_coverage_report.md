# 테스트 커버리지 분석 보고서

생성일: 2025-07-19T00:09:57.449370

## 📊 전체 통계

| 항목 | 값 |
|------|-----|
| 총 파일 수 | 30 |
| 총 라인 수 | 3150 |
| 커버된 라인 수 | 47 |
| 전체 커버리지 | 1.49% |

## 🎯 Group Workout Community 커버리지

| 항목 | 값 |
|------|-----|
| 파일 수 | 18 |
| 총 라인 수 | 1723 |
| 커버된 라인 수 | 44 |
| 커버리지 | 2.55% |

## 📁 파일별 상세 분석

| 파일 | 커버리지 | 커버된 라인 | 총 라인 | 상태 |
|------|----------|-------------|---------|------|
| failures.dart | 0.0% | 0 | 12 | ❌ 개선필요 |
| workout_program_failures.dart | 0.0% | 0 | 65 | ❌ 개선필요 |
| base_repository.dart | 0.0% | 0 | 22 | ❌ 개선필요 |
| post_comment.dart | 0.0% | 0 | 33 | ❌ 개선필요 |
| post_search_criteria.dart | 0.0% | 0 | 129 | ❌ 개선필요 |
| body_part_mapping.dart | 0.0% | 0 | 43 | ❌ 개선필요 |
| workout_score_calculation.dart | 0.0% | 0 | 70 | ❌ 개선필요 |
| accessibility_utils.dart | 0.0% | 0 | 123 | ❌ 개선필요 |
| breakpoint_utils.dart | 0.0% | 0 | 51 | ❌ 개선필요 |
| ux_optimization_utils.dart | 0.0% | 0 | 204 | ❌ 개선필요 |
| group_card.dart | 0.0% | 0 | 183 | ❌ 개선필요 |
| app_localizations_en.dart | 0.0% | 0 | 351 | ❌ 개선필요 |
| app_localizations_ko.dart | 0.0% | 0 | 351 | ❌ 개선필요 |
| bloc_event_bus.dart | 0.0% | 0 | 84 | ❌ 개선필요 |
| bloc_errors.dart | 0.0% | 0 | 70 | ❌ 개선필요 |
| group_search_criteria.dart | 0.0% | 0 | 73 | ❌ 개선필요 |
| group_bloc.dart | 0.0% | 0 | 607 | ❌ 개선필요 |
| group_ranking.dart | 1.3% | 1 | 76 | ❌ 개선필요 |
| user_workout_score.dart | 1.3% | 1 | 75 | ❌ 개선필요 |
| community_post.dart | 1.8% | 1 | 57 | ❌ 개선필요 |
| group_state.dart | 2.2% | 4 | 184 | ❌ 개선필요 |
| group_event.dart | 2.5% | 2 | 79 | ❌ 개선필요 |
| base_bloc.dart | 2.6% | 2 | 77 | ❌ 개선필요 |
| post_category.dart | 4.3% | 1 | 23 | ❌ 개선필요 |
| app_localizations.dart | 5.9% | 1 | 17 | ❌ 개선필요 |
| workout_group.dart | 6.3% | 2 | 32 | ❌ 개선필요 |
| group_member.dart | 12.9% | 4 | 31 | ❌ 개선필요 |
| community_repository.dart | 100.0% | 4 | 4 | ✅ 양호 |
| ranking_repository.dart | 100.0% | 21 | 21 | ✅ 양호 |
| group_repository.dart | 100.0% | 3 | 3 | ✅ 양호 |

## 🔍 품질 분석

- **높은 커버리지 (≥80%)**: 3개 파일
- **중간 커버리지 (50-79%)**: 0개 파일
- **낮은 커버리지 (<50%)**: 27개 파일

## 📋 개선 권장사항

1. 17개 파일의 커버리지가 0%입니다. 기본 테스트 케이스 추가가 필요합니다.
2. 10개 파일의 커버리지가 50% 미만입니다. 추가 테스트 케이스가 필요합니다.
3. Group Workout Community 기능의 15개 파일이 70% 미만의 커버리지를 가집니다.
4. 테스트 실행 전 모든 컴파일 에러를 수정해야 합니다.
5. Mock 객체와 실제 인터페이스 간의 불일치를 해결해야 합니다.
6. BLoC 이벤트 및 상태 클래스의 생성자 시그니처를 확인해야 합니다.

## 🚨 발견된 주요 문제점

### 컴파일 에러
- LogicalKeyboardKey import 누락
- GroupActivityType 타입 정의 문제
- BlocCommunicationEvent 추상 클래스 인스턴스화 시도
- Mock 객체 타입 불일치

### 테스트 구조 문제
- 실제 구현과 테스트 코드 간 인터페이스 불일치
- 존재하지 않는 상태 클래스 참조
- 잘못된 매개변수 이름 사용

## 🎯 다음 단계

1. **즉시 수정 필요**: 모든 컴파일 에러 해결
2. **단기 목표**: Group Workout Community 테스트 70% 이상 커버리지 달성
3. **중기 목표**: 전체 테스트 스위트 안정화
4. **장기 목표**: 지속적인 테스트 품질 모니터링 체계 구축
