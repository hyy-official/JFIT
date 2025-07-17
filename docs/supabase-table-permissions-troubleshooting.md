# Supabase 테이블 권한 문제 해결 가이드

## 문제 상황

새로운 테이블을 생성한 후 앱에서 데이터 삽입/수정/삭제 시 다음과 같은 에러가 발생하는 경우:

```
PostgrestException(message: permission denied for table [table_name], code: 42501, details: Forbidden, hint: null)
```

## 원인 분석

### 1. RLS (Row Level Security) vs 테이블 권한

많은 개발자들이 RLS 정책 문제로 생각하지만, 실제로는 **테이블 레벨의 기본 권한**이 부여되지 않은 경우가 많습니다.

- **RLS**: 행 단위 보안 정책 (사용자별 데이터 접근 제어)
- **테이블 권한**: PostgreSQL의 기본 테이블 접근 권한 (역할별 CRUD 권한)

### 2. 권한 계층 구조

```
PostgreSQL 테이블 권한 (상위)
    ↓
RLS 정책 (하위)
    ↓
실제 데이터 접근
```

테이블 권한이 없으면 RLS 정책과 관계없이 접근이 차단됩니다.

## 진단 방법

### 1. 테이블 권한 확인

```sql
-- 특정 테이블의 역할별 권한 확인
SELECT 
    t.schemaname,
    t.tablename,
    pg_catalog.has_table_privilege('anon', t.schemaname||'.'||t.tablename, 'INSERT') as anon_can_insert,
    pg_catalog.has_table_privilege('authenticated', t.schemaname||'.'||t.tablename, 'INSERT') as auth_can_insert,
    pg_catalog.has_table_privilege('service_role', t.schemaname||'.'||t.tablename, 'INSERT') as service_can_insert,
    pg_catalog.has_table_privilege('anon', t.schemaname||'.'||t.tablename, 'SELECT') as anon_can_select,
    pg_catalog.has_table_privilege('authenticated', t.schemaname||'.'||t.tablename, 'SELECT') as auth_can_select,
    pg_catalog.has_table_privilege('service_role', t.schemaname||'.'||t.tablename, 'SELECT') as service_can_select
FROM pg_tables t
WHERE t.tablename = 'your_table_name';
```

### 2. RLS 상태 확인

```sql
-- 테이블의 RLS 활성화 상태 확인
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'your_table_name';

-- RLS 정책 확인
SELECT tablename, policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'your_table_name';
```

### 3. 정상 작동하는 테이블과 비교

```sql
-- 정상 작동하는 테이블과 권한 비교
SELECT 
    t.tablename,
    pg_catalog.has_table_privilege('anon', t.schemaname||'.'||t.tablename, 'INSERT') as anon_can_insert,
    pg_catalog.has_table_privilege('authenticated', t.schemaname||'.'||t.tablename, 'INSERT') as auth_can_insert
FROM pg_tables t
WHERE t.tablename IN ('working_table', 'problem_table')
ORDER BY t.tablename;
```

## 해결 방법

### 1. 테이블 권한 부여 (가장 일반적인 해결책)

```sql
-- 모든 필요한 권한 부여
GRANT ALL ON TABLE your_table_name TO anon;
GRANT ALL ON TABLE your_table_name TO authenticated;
GRANT ALL ON TABLE your_table_name TO service_role;

-- 시퀀스 권한도 함께 부여 (UUID 생성 등을 위해)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO service_role;
```

### 2. 선택적 권한 부여

```sql
-- 읽기 전용
GRANT SELECT ON TABLE your_table_name TO anon;

-- 읽기/쓰기
GRANT SELECT, INSERT, UPDATE ON TABLE your_table_name TO authenticated;

-- 모든 권한
GRANT ALL ON TABLE your_table_name TO service_role;
```

### 3. RLS 설정 (권한 부여 후)

```sql
-- RLS 활성화
ALTER TABLE your_table_name ENABLE ROW LEVEL SECURITY;

-- 사용자별 데이터 접근 정책
CREATE POLICY "Users can access their own data" ON your_table_name
    FOR ALL USING (auth.uid() = user_id);
```

## 예방 방법

### 1. 테이블 생성 시 권한 자동 부여

```sql
-- 테이블 생성과 동시에 권한 부여
CREATE TABLE your_table_name (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    -- 기타 컬럼들...
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 즉시 권한 부여
GRANT ALL ON TABLE your_table_name TO anon, authenticated, service_role;
```

### 2. 마이그레이션 템플릿 사용

```sql
-- 표준 마이그레이션 템플릿
CREATE TABLE IF NOT EXISTS your_table_name (
    -- 테이블 정의
);

-- 권한 부여
GRANT ALL ON TABLE your_table_name TO anon, authenticated, service_role;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

-- RLS 설정 (필요한 경우)
ALTER TABLE your_table_name ENABLE ROW LEVEL SECURITY;
CREATE POLICY "policy_name" ON your_table_name FOR ALL USING (auth.uid() = user_id);
```

## 실제 사례: todos 테이블

### 문제 상황
- `todos` 테이블 생성 후 INSERT 시 permission denied 에러
- RLS 비활성화해도 동일한 에러 발생

### 진단 결과
```sql
-- todos 테이블 권한 확인 결과
anon_can_insert: false
auth_can_insert: false
service_can_insert: false

-- 정상 작동하는 user_meal_entries 테이블
anon_can_insert: true
auth_can_insert: true
```

### 해결
```sql
GRANT ALL ON TABLE todos TO anon;
GRANT ALL ON TABLE todos TO authenticated;
GRANT ALL ON TABLE todos TO service_role;
```

## 주의사항

### 1. 보안 고려사항
- `anon` 역할에 모든 권한을 부여하는 것은 보안상 위험할 수 있음
- 프로덕션 환경에서는 최소 권한 원칙 적용
- RLS 정책으로 행 단위 보안 강화 필요

### 2. 개발 vs 프로덕션
```sql
-- 개발 환경: 편의성 우선
GRANT ALL ON TABLE your_table_name TO anon, authenticated, service_role;

-- 프로덕션 환경: 보안 우선
GRANT SELECT ON TABLE your_table_name TO anon;
GRANT SELECT, INSERT, UPDATE ON TABLE your_table_name TO authenticated;
-- RLS 정책으로 세밀한 제어
```

### 3. 환경 변수 확인
- `SUPABASE_ANON_KEY` vs `SUPABASE_SERVICE_KEY` 사용 확인
- 개발 환경에서는 service_role 키 사용 고려

## 체크리스트

새 테이블 생성 시 다음 사항들을 확인하세요:

- [ ] 테이블 권한 부여 (`GRANT` 문 실행)
- [ ] 시퀀스 권한 부여 (UUID 사용 시)
- [ ] RLS 정책 설정 (필요한 경우)
- [ ] 권한 확인 쿼리로 검증
- [ ] 실제 앱에서 CRUD 테스트
- [ ] 에러 로그 확인

## 관련 링크

- [Supabase RLS 문서](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL 권한 관리](https://www.postgresql.org/docs/current/sql-grant.html)
- [Supabase 권한 문제 해결](https://supabase.com/docs/guides/database/postgres/row-level-security)