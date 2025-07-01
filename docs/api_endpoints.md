# 운동 데이터베이스 API 명세서

## 🔐 인증

모든 API 요청은 JWT 토큰을 Authorization 헤더에 포함해야 합니다.
```
Authorization: Bearer <jwt_token>
```

## 📋 API 엔드포인트

### 🔑 인증 관련

#### POST /api/auth/register
사용자 회원가입
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동"
}
```

#### POST /api/auth/login
사용자 로그인
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### POST /api/auth/refresh
토큰 갱신
```json
{
  "refresh_token": "refresh_token_here"
}
```

#### POST /api/auth/logout
로그아웃 (토큰 무효화)

---

### 🏋️ 운동 프로그램

#### GET /api/programs
운동 프로그램 목록 조회
```
Query Parameters:
- page: 페이지 번호 (기본값: 1)
- limit: 페이지 크기 (기본값: 20)
- difficulty: 난이도 필터 (beginner, intermediate, advanced)
- type: 프로그램 타입 (strength, hypertrophy, powerlifting, bodybuilding)
- search: 검색어
- popular: 인기 프로그램만 (true/false)
```

#### GET /api/programs/:id
특정 운동 프로그램 상세 조회

#### POST /api/programs
새 운동 프로그램 생성 (관리자 전용)
```json
{
  "name": "내 커스텀 프로그램",
  "description": "설명",
  "duration_weeks": 8,
  "difficulty_level": "intermediate",
  "program_type": "strength",
  "workouts_per_week": 3,
  "equipment_needed": ["바벨", "덤벨"],
  "weekly_schedule": [...],
  "tags": ["근력", "중급"]
}
```

#### PUT /api/programs/:id
운동 프로그램 수정

#### DELETE /api/programs/:id
운동 프로그램 삭제

#### POST /api/programs/:id/rate
프로그램 평점 등록
```json
{
  "rating": 5,
  "review": "정말 좋은 프로그램입니다!"
}
```

#### POST /api/programs/:id/favorite
프로그램 즐겨찾기 추가/제거

---

### 💪 운동 기록

#### GET /api/exercises
사용자의 운동 기록 조회
```
Query Parameters:
- date_from: 시작 날짜 (YYYY-MM-DD)
- date_to: 종료 날짜 (YYYY-MM-DD)
- exercise_type: 운동 타입 필터
- limit: 개수 제한
```

#### POST /api/exercises
새 운동 기록 추가
```json
{
  "exercise_name": "벤치프레스",
  "exercise_type": "strength",
  "duration_minutes": 60,
  "calories_burned": 300,
  "intensity": "high",
  "exercise_date": "2024-01-15",
  "weight": 80.0,
  "sets": 3,
  "reps": 8,
  "notes": "PR 달성!"
}
```

#### PUT /api/exercises/:id
운동 기록 수정

#### DELETE /api/exercises/:id
운동 기록 삭제

#### GET /api/exercises/stats
운동 통계 조회 (주간/월간 요약)

---

### 🥗 음식 및 식사 기록

#### GET /api/foods
음식 데이터베이스 검색
```
Query Parameters:
- search: 검색어
- barcode: 바코드
- category: 카테고리
- limit: 개수 제한
```

#### POST /api/foods
새 음식 추가 (사용자 생성)
```json
{
  "name": "사용자 추가 음식",
  "serving_size_g": 100,
  "calories": 250,
  "protein": 20,
  "carbohydrates": 30,
  "fat": 8
}
```

#### GET /api/meals
사용자의 식사 기록 조회
```
Query Parameters:
- date_from: 시작 날짜
- date_to: 종료 날짜
- meal_type: 식사 타입 (breakfast, lunch, dinner, snack)
```

#### POST /api/meals
새 식사 기록 추가
```json
{
  "food_item_id": "uuid",
  "food_name": "닭가슴살",
  "meal_type": "lunch",
  "quantity_g": 200,
  "entry_date": "2024-01-15",
  "calories": 330,
  "protein": 62,
  "carbohydrates": 0,
  "fat": 7.2
}
```

#### PUT /api/meals/:id
식사 기록 수정

#### DELETE /api/meals/:id
식사 기록 삭제

#### GET /api/meals/stats
영양 섭취 통계 조회

---

### 🏃 운동 세션

#### GET /api/sessions
사용자의 운동 세션 조회

#### POST /api/sessions
새 운동 세션 시작
```json
{
  "session_name": "오늘의 가슴 운동",
  "workout_program_id": "uuid",
  "start_time": "2024-01-15T09:00:00Z"
}
```

#### PUT /api/sessions/:id
운동 세션 업데이트 (진행 중인 운동 기록)
```json
{
  "exercises": [
    {
      "name": "벤치프레스",
      "sets": [
        {"weight": 80, "reps": 8, "completed": true},
        {"weight": 85, "reps": 6, "completed": true}
      ]
    }
  ]
}
```

#### POST /api/sessions/:id/complete
운동 세션 완료
```json
{
  "end_time": "2024-01-15T10:30:00Z",
  "notes": "좋은 세션이었다!"
}
```

---

### 🔄 동기화

#### GET /api/sync/changes
특정 시점 이후의 변경사항 조회
```
Query Parameters:
- since: 마지막 동기화 시간 (ISO 8601)
- tables: 동기화할 테이블 목록 (쉼표 구분)
```

#### POST /api/sync/push
클라이언트 변경사항을 서버로 전송
```json
{
  "changes": [
    {
      "table": "user_exercises",
      "operation": "insert",
      "data": {...},
      "client_timestamp": "2024-01-15T10:00:00Z"
    }
  ]
}
```

#### POST /api/sync/resolve-conflicts
동기화 충돌 해결
```json
{
  "conflicts": [
    {
      "record_id": "uuid",
      "table": "user_exercises",
      "resolution": "use_server", // "use_client", "merge"
      "merged_data": {...}
    }
  ]
}
```

---

### 📊 통계 및 분석

#### GET /api/stats/dashboard
대시보드용 전체 통계
```json
{
  "timeframe": "week", // "week", "month", "year"
  "timezone": "Asia/Seoul"
}
```

#### GET /api/stats/progress
사용자 진전 추적
```
Query Parameters:
- metric: 추적할 지표 (weight, strength, volume)
- period: 기간 (7d, 30d, 90d, 1y)
```

#### GET /api/stats/leaderboard
리더보드 (선택적 기능)

---

### 👤 사용자 프로필

#### GET /api/profile
사용자 프로필 조회

#### PUT /api/profile
사용자 프로필 수정
```json
{
  "name": "새로운 이름",
  "profile_image_url": "https://...",
  "timezone": "Asia/Seoul"
}
```

#### DELETE /api/profile
계정 삭제

---

### 🔔 알림 (선택적)

#### GET /api/notifications
사용자 알림 목록

#### POST /api/notifications/mark-read
알림 읽음 처리

#### PUT /api/notifications/settings
알림 설정 변경

---

## 📝 응답 형식

### 성공 응답
```json
{
  "success": true,
  "data": {...},
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

### 오류 응답
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

## 🚀 실시간 기능 (WebSocket)

### 연결
```
wss://api.yourdomain.com/ws?token=<jwt_token>
```

### 이벤트
- `workout_session_updated`: 실시간 운동 세션 업데이트
- `sync_notification`: 다른 기기에서 데이터 변경 알림
- `program_recommendation`: 새로운 프로그램 추천

## 🔒 보안 고려사항

1. **Rate Limiting**: API 호출 횟수 제한
2. **Input Validation**: 모든 입력 데이터 검증
3. **SQL Injection 방지**: 파라미터화된 쿼리 사용
4. **CORS 설정**: 허용된 도메인만 접근
5. **HTTPS 강제**: 모든 통신 암호화
6. **토큰 만료**: JWT 토큰 적절한 만료 시간 설정 