# JFit 네비게이션 규칙

본 문서는 프로젝트 전반에서 일관된 페이지 전환 UX 를 유지하기 위한 **Navigator 사용 가이드라인**을 설명합니다.

## 1. Route 계층 정의

| 계층 | 정의 | 예시 페이지 | 뒤로가기 필요 | 전환 API |
|---|---|---|---|---|
| **Root Route** | 앱의 최상위(메인) 화면, 혹은 동등 계층의 독립 흐름 | `MainNavigationPage`, `LoginPage`, `RegisterPage`, `OnBoardingPage` | 필요 없음 | `pushAndRemoveUntil()` *(스택 초기화)* |
| **Detail Route** | Root 내부에서 탐색되는 하위 화면 | 프로그램 목록 ➜ 상세, 상세 ➜ 세션 등 | 필요함 | `push()` |

> Root → Root 전환 시 기존 스택은 **모두 제거**하여 뒤로가기/스와이프를 비활성화합니다.

## 2. Navigator API 선택 기준

1. **`push(context, route)`**  
   • 디테일 페이지 진입 시 사용  
   • 이전 페이지로 스와이프/뒤로가기 가능해야 할 때

2. **`pushAndRemoveUntil(context, route, (r) => false)`**  
   • 새로운 Root Route 로 전환하며 **스택을 비움**  
   • 로그인 → 메인, 세션 완료 → 메인, 회원가입 → 로그인 등

3. **`popUntil((r) => r.isFirst)`**  
   • 여러 단계 디테일을 모두 닫고 Root 로 복귀할 때  
   • 예: 세션 진행 → 결과 페이지 → 확인 버튼 시

> `pushReplacement` 는 가급적 사용하지 않습니다. 유지해야 하는 하위 스택이 특수하게 존재할 때만 예외적으로 허용합니다.

## 3. 예시 코드 스니펫

```dart
// Root → Root (세션 완료 후 홈)
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const MainNavigationPage(initialIndex: 0)),
  (route) => false,
);

// Root 내부 디테일 진입 (프로그램 상세 보기)
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => ProgramDetailPage(program: program)),
);

// 디테일 스택 전부 닫고 홈으로
Navigator.of(context).popUntil((r) => r.isFirst);
```

## 4. 플랫폼별 전환 애니메이션

* 데스크톱(Windows·macOS·Linux) : **FadeUpwards**
* iOS : **Cupertino (스와이프 지원)**
* Android : 기본 Material3 전환

`AppTheme` 의 `pageTransitionsTheme` 에서 플랫폼별 전환 빌더를 지정해두었습니다.

## 5. 적용 범위

- **`lib/features`** 의 모든 Presentation 레이어
- **`lib/core/navigation`**
- 테스트 및 예제 코드는 예외

규칙을 준수하여 새 페이지/기능을 추가해 주세요. 