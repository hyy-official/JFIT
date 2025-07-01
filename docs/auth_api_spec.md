# JFiT 인증/SSO 백엔드 명세

> 작성일: 2025-06-30  
> 작성자: 모바일 팀 (Flutter)

## 1. 목표
1. 이메일/비밀번호 기반 회원가입·로그인 구현.
2. JWT(access + refresh) 토큰 방식으로 **자동 로그인** 지원.
3. Google · Apple · Kakao **SSO** 지원(확장 가능 구조).
4. 토큰 만료, 로그아웃, 계정 삭제 등 전반적인 인증 라이프사이클 정의.

---

## 2. API Endpoints
| 메소드 | 경로 | 설명 |
|--------|------|-----|
| POST | `/auth/register` | 회원가입 (email, password, name) |
| POST | `/auth/login` | 로그인 (email, password) |
| POST | `/auth/refresh` | Refresh-Token으로 Access-Token 재발급 |
| POST | `/auth/logout` | Refresh-Token 무효화 & 로그아웃 |
| POST | `/auth/social/{provider}` | SSO (Google/Apple/Kakao) 인증 코드 ↔ JWT 교환 |
| POST | `/auth/forgot-password` | 비밀번호 재설정 이메일 발송 |
| POST | `/auth/reset-password` | 토큰 + 새 비밀번호로 재설정 |
| DELETE | `/profile` | 사용자 계정 삭제 |

### 공통 성공 응답 (`200/201`)
```json
{
  "data": {
    "access_token": "<jwt>",
    "refresh_token": "<uuid>",
    "expires_in": 900,          // 초(15분)
    "user": {
      "id": "uuid",
      "email": "user@mail.com",
      "name": "홍길동"
    }
  }
}
```

### 공통 에러 응답
```json
{
  "error": {
    "code": 401,
    "message": "Invalid credentials"
  }
}
```

---

## 3. JWT & Refresh Token 정책
| 항목 | 값 |
|------|----|
| Access-Token 만료 | 15분 |
| Refresh-Token 만료 | 14일 (재발급 시 Rolling) |
| 서명 알고리즘 | HS256 (비밀키 ENV: `JWT_SECRET`) |
| Payload 최소 항목 | `sub`(userId), `email`, `iat`, `exp` |

*모바일→서버 요청 시 `Authorization: Bearer <access>` 헤더 사용*

### Refresh Flow
1. Access-Token 만료 → 401 수신.
2. 앱은 `POST /auth/refresh` 로 Refresh-Token 제출.
3. 서버는 DB 테이블(`refresh_tokens`)에서 유효성·만료 확인 후 새 Access-Token 반환.
4. 실패 시 앱은 사용자 로그아웃 처리.

---

## 4. SSO
| Provider | 모바일 SDK | 서버 처리 |
|----------|-----------|-----------|
| Google | `google_sign_in` | OAuth code → Google Token → 사용자 이메일 획득 후 JWT 발급 |
| Apple | `sign_in_with_apple` | id_token(Apple) 검증 → 이메일 획득 → JWT |
| Kakao | `kakao_flutter_sdk_login` | OAuth code → Kakao API → 이메일 → JWT |

*모바일은 provider SDK 로 authorization code/id_token 을 얻어 서버로 POST.*

```http
POST /auth/social/google
{ "code": "<auth_code>", "redirect_uri": "..." }
```

---

## 5. 데이터베이스
```mermaid
erDiagram
    users ||--o{ refresh_tokens : "1:N"
    users {
      uuid id PK
      varchar email UNIQUE
      varchar password_hash
      varchar name
      timestamp created_at
    }
    refresh_tokens {
      uuid id PK
      uuid user_id FK
      varchar token UNIQUE
      timestamp expires_at
      varchar user_agent
      varchar ip
    }
```

---

## 6. 보안 & 운영
- HTTPS 필수.
- 비밀번호 `bcrypt` 12 rounds.
- Refresh-Token 블랙리스트 테이블.
- Rate-Limit: 로그인 5회/분, 비밀번호 재설정 3회/시간.
- 이메일 인증(선택) → `is_email_verified` 플래그.

---

## 7. TODO / 요청 사항 (백엔드팀)
1. 위 명세대로 엔드포인트 및 DB 스키마 구현.
2. 환경변수:
   - `JWT_SECRET`, `REFRESH_TOKEN_TTL`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` 등.
3. Swagger/OpenAPI 문서화.
4. Staging 서버 배포 & 테스트 계정 공유.
5. 완료 후 Flutter 팀에 Postman 컬렉션 전달.

---

> 문의: mobile@jfit.com / Slack #jfit-mobile 