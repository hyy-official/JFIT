# JFiT 다국어 지원 (Localization) 가이드

## 📋 **현재 구현된 기능**

### ✅ **기본 설정 완료**
- `flutter_localizations` 및 `intl` 패키지 추가
- `l10n.yaml` 설정 파일 생성
- ARB 파일을 통한 번역 관리 시스템 구축

### ✅ **번역 파일 위치**
- `lib/l10n/app_en.arb` - 영어 번역
- `lib/l10n/app_ko.arb` - 한국어 번역

### ✅ **언어 상태 관리**
- `LocaleManager` 클래스로 언어 상태 관리
- 위치: `lib/core/utils/locale_manager.dart`

---

## 🎯 **향후 사용할 기능들**

### 1. **언어 전환 버튼 구현 방법**

설정 페이지나 프로필 페이지에서 언어 전환 기능을 추가할 때 사용:

```dart
import 'package:jfit/core/utils/locale_manager.dart';

// 언어 토글 버튼
IconButton(
  icon: Icon(Icons.language),
  onPressed: () {
    LocaleManager().toggleLocale();
  },
  tooltip: 'Change Language',
)

// 또는 드롭다운 메뉴
DropdownButton<Locale>(
  value: LocaleManager().currentLocale,
  items: [
    DropdownMenuItem(
      value: Locale('ko'),
      child: Text('한국어'),
    ),
    DropdownMenuItem(
      value: Locale('en'), 
      child: Text('English'),
    ),
  ],
  onChanged: (locale) {
    if (locale != null) {
      LocaleManager().setLocale(locale);
    }
  },
)
```

### 2. **현재 언어 확인 방법**

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Context에서 현재 언어 정보 가져오기
final l10n = AppLocalizations.of(context);
final currentLanguage = l10n?.localeName; // 'ko' 또는 'en'

// LocaleManager에서 직접 확인
final currentLocale = LocaleManager().currentLocale;
final isKorean = currentLocale.languageCode == 'ko';
```

### 3. **새로운 번역 추가 방법**

1. **ARB 파일에 번역 추가**:
   ```json
   // app_en.arb
   {
     "newText": "New Text in English"
   }
   
   // app_ko.arb  
   {
     "newText": "새로운 한국어 텍스트"
   }
   ```

2. **코드 생성**:
   ```bash
   flutter gen-l10n
   ```

3. **코드에서 사용**:
   ```dart
   Text(l10n?.newText ?? 'Fallback Text')
   ```

### 4. **동적 텍스트 처리**

매개변수가 있는 번역:

```json
// ARB 파일
{
  "welcomeMessage": "안녕하세요, {userName}님!",
  "@welcomeMessage": {
    "placeholders": {
      "userName": {
        "type": "String"
      }
    }
  }
}
```

```dart
// 사용 방법
Text(l10n.welcomeMessage('홍길동'))
```

---

## 🔧 **설정 페이지 구현 예시**

```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language),
            title: Text(l10n?.language ?? 'Language'),
            trailing: DropdownButton<Locale>(
              value: LocaleManager().currentLocale,
              items: [
                DropdownMenuItem(
                  value: Locale('ko'),
                  child: Text('한국어'),
                ),
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  LocaleManager().setLocale(locale);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📚 **현재 번역된 항목들**

### **메인 항목**
- `appTitle`: JFiT / FitTrack
- `workoutDashboard`: 운동 대시보드 / Workout Dashboard
- `currentDate`: 2025년 6월 24일 화요일 / Tuesday, June 24th, 2025

### **통계 카드**
- `todaysWorkout`: 오늘의 운동 / Today's Workout
- `keepMomentum`: 계속 열심히 하세요 / Keep the momentum
- `totalSessions`: 총 세션 / Total Sessions
- `consistencyMatters`: 꾸준함이 중요해요 / Consistency matters
- `timeInvested`: 투자한 시간 / Time Invested
- `yourDedication`: 당신의 노력 / Your dedication
- `caloriesBurned`: 소모한 칼로리 / Calories Burned
- `energyTransformed`: 에너지 변환 / Energy transformed
- `todaysIntake`: 오늘의 섭취량 / Today's Intake
- `caloriesConsumed`: 섭취한 칼로리 / Calories consumed

### **차트 및 운동**
- `weeklyWorkoutDuration`: 주간 운동 시간 / Weekly Workout Duration
- `weeklyNutritionIntake`: 주간 영양 섭취량 / Weekly Nutrition Intake
- `recentWorkouts`: 최근 운동 / Recent Workouts
- `squat`: 스쿼트 / Squat
- `benchPress`: 벤치프레스 / Bench Press
- `deadlift`: 데드리프트 / Deadlift
- `strength`: 근력 / Strength

### **영양소**
- `protein`: 단백질 (g) / Protein (g)
- `carbs`: 탄수화물 (g) / Carbs (g)
- `fat`: 지방 (g) / Fat (g)

### **기타**
- `aiFeaturePreparing`: AI 기능을 준비 중입니다 / AI feature is under preparation
- `duration`: 시간 / Duration
- `calories`: 칼로리 / Calories
- `type`: 유형 / Type
- `date`: 날짜 / Date

---

## 🚀 **사용 시 주의사항**

1. **코드 생성**: 새로운 번역 추가 후 반드시 `flutter gen-l10n` 실행
2. **Fallback**: 항상 `??` 연산자로 기본값 제공
3. **Context**: `AppLocalizations.of(context)`는 BuildContext가 필요
4. **Hot Reload**: 언어 변경 시 전체 앱이 다시 빌드됨

---

## 📝 **TODO: 향후 추가할 번역 항목들**

- [ ] 설정 페이지 관련 텍스트
- [ ] 운동 프로그램 관련 텍스트  
- [ ] 에러 메시지들
- [ ] 성공/실패 알림 메시지들
- [ ] 폼 검증 메시지들
- [ ] 로딩 상태 메시지들 