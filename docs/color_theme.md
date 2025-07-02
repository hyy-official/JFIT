JFIT 다크 피트니스 테마 컬러 명세서 (Flutter 적용 기준)
========================================================

1. 테마 개요
------------
- JFiT 다크 피트니스 테마는 깊이감 있는 다크모드를 기본으로, 인디고(Indigo)와 퍼플(Purple) 그라데이션을 핵심 포인트로 사용합니다.
- 모든 색상은 **명확한 계층/위계와 목적**을 갖고, **일관된 UI/UX**를 위해 아래 팔레트 외 색상 사용을 엄격히 제한합니다.

2. UI 계층 구조 및 역할별 색상
-----------------------------
| 역할 (Role)           | 색상 코드 (Flutter)   | 사용 예시/적용 위치                                                      |
|-----------------------|----------------------|--------------------------------------------------------------------------|
| 기본 배경             | `Color(0xFF0A0A0A)`  | 앱의 메인 배경, Scaffold, 전체 캔버스                                    |
| 보조 배경             | `Color(0xFF111111)`  | 사이드바, 패널, drawer, 탭 비선택 배경                                   |
| 카드/차트 Surface     | `Color(0xFF1A1A1A)`  | 카드, 차트, GlassCard, 다이얼로그 등 표면                                |
| 카드/차트 Hover       | `Color(0xFF1F1F1F)`  | 카드 Hover/Pressed, 클릭시                                               |
| 기본 텍스트           | `Colors.white`       | 제목, 주요 정보, 값(데이터), 강조 텍스트                                 |
| 보조 텍스트           | `Color(0xFFA3A3A3)`  | 본문, 설명, 날짜, 범례, 일반 상태                                        |
| 비활성/뮤트 텍스트    | `Color(0xFF737373)`  | placeholder, 안내문구, 비활성화 정보, 축/보조선, 기타 라벨               |
| 강조(Accent) - Indigo| `Color(0xFF6366F1)`  | Gradient 시작, 아이콘, 미니버튼, 탭/버튼 active dot 등                   |
| 강조(Accent) - Purple| `Color(0xFF8B5CF6)`  | Gradient 끝, 주요 액션/포인트, 미니 버튼 등                               |
| 보더/구분선           | `Color(0xFF262626)`  | 카드, 섹션, 차트 축, Divider 등                                          |
| 보더 Hover            | `Color(0xFF404040)`  | 카드 Hover/Active, 강조시                                                |
| Accent Gradient       | `LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])` | 주요 CTA, 선택 탭, Progress, 활성 버튼                                   |

3. 데이터 시각화(차트) 팔레트
-----------------------------
- 모든 Bar, Pie, Line 차트 등에서 **아래 팔레트를 순서대로 반복해서 사용** (데이터 구분/카테고리/범례 등)

| 색상명   | 코드           | 사용 위치 (예시)                    |
|----------|---------------|-------------------------------------|
| 퍼플     | #8B5CF6       | 기본 데이터(첫번째), 주요 바/선/영역 |
| 인디고   | #6366F1       | 두번째 계열/보조                    |
| 청록     | #22D3EE       | 세번째 데이터/신선/활동              |
| 라임     | #A3E635       | 긍정적/네번째 데이터                 |
| 오렌지   | #F59E42       | 경고/다섯번째 데이터/포인트          |

4. Glass Morphism 효과
----------------------
- **카드/차트 등 주요 Surface**는
  - `Color(0xFF1A1A1A).withOpacity(0.75)`
  - + `BackdropFilter(blur: 12~24)`
  - + `BoxShadow`, border 적용
- 단, Blur/Glass 효과는 **최상위 Surface/Card/차트 등에서만** 사용하며, 남용하지 않습니다.

5. 컬러 적용 규칙 및 주의사항
-----------------------------
- **배경 계층**
  1. 기본 배경 → 2. 보조 배경 → 3. 카드/차트 Surface (항상 3단계 Layer 구조로 적용)
- **Accent Gradient**는 “선택됨”, CTA 버튼, 활성 탭/메뉴, 메인 Progress 등 “사용자 시선을 유도해야 하는 영역”에서만 사용
- **개별 Accent 컬러**는 작은 아이콘, 미니 포인트, 버튼 등에서만 사용
- **차트 시각화**: 데이터 값(Bar, Pie, Line 등)은 반드시 지정 팔레트로, 축/범례/라벨/그리드 등은 textMuted 또는 border 컬러
- **카드/섹션**: Glass Morphism 효과를 항상 적용(투명+Blur+Shadow+Radius)
- **팔레트 외 색상, 파스텔/강조색, 밝은톤**: 무단 사용 절대 금지

6. Flutter 코드 예시
---------------------
```dart
// Accent Gradient 예시
final accentGradient = LinearGradient(
  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// 차트 팔레트 예시
final chartColors = [
  Color(0xFF8B5CF6),
  Color(0xFF6366F1),
  Color(0xFF22D3EE),
  Color(0xFFA3E635),
  Color(0xFFF59E42),
];

// Glass Morphism 카드 예시
BoxDecoration glassCardDecoration = BoxDecoration(
  color: Color(0xFF1A1A1A).withOpacity(0.75),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: Color(0xFF262626)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ],
);

