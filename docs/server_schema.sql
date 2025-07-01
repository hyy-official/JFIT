-- 운동 데이터베이스 서버 스키마
-- PostgreSQL 기준

-- 사용자 테이블
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    profile_image_url TEXT,
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

-- 운동 프로그램 마스터 테이블
CREATE TABLE workout_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    creator VARCHAR(100) NOT NULL,
    description TEXT,
    duration_weeks INTEGER NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    program_type VARCHAR(30) NOT NULL CHECK (program_type IN ('strength', 'hypertrophy', 'powerlifting', 'bodybuilding', 'cardio')),
    workouts_per_week INTEGER,
    equipment_needed JSONB, -- ['바벨', '덤벨', '벤치']
    weekly_schedule JSONB,  -- 주간 스케줄 JSON
    tags JSONB,            -- ['초급', '근력', '복합운동']
    rating DECIMAL(2,1) DEFAULT 0.0,
    total_ratings INTEGER DEFAULT 0,
    is_popular BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    version INTEGER DEFAULT 1
);

-- 사용자별 운동 기록
CREATE TABLE user_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    exercise_name VARCHAR(100) NOT NULL,
    exercise_type VARCHAR(30) NOT NULL,
    duration_minutes INTEGER,
    calories_burned INTEGER,
    intensity VARCHAR(20),
    exercise_date DATE NOT NULL,
    weight DECIMAL(5,2),
    sets INTEGER,
    reps INTEGER,
    notes TEXT,
    workout_program_id UUID REFERENCES workout_programs(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 음식 마스터 데이터
CREATE TABLE food_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    brand VARCHAR(100),
    serving_size_g DECIMAL(7,2),
    calories DECIMAL(7,2) NOT NULL,
    protein DECIMAL(6,2) NOT NULL,
    carbohydrates DECIMAL(6,2) NOT NULL,
    fat DECIMAL(6,2) NOT NULL,
    fiber DECIMAL(6,2),
    sugar DECIMAL(6,2),
    sodium DECIMAL(7,2),
    category VARCHAR(50),
    barcode VARCHAR(20),
    source VARCHAR(50), -- 'user_created', 'fdc', 'manual'
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 사용자별 식사 기록
CREATE TABLE user_meal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    food_item_id UUID REFERENCES food_items(id),
    food_name VARCHAR(200) NOT NULL, -- 음식이 삭제되어도 기록 유지
    meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    quantity_g DECIMAL(7,2) NOT NULL,
    entry_date DATE NOT NULL,
    calories DECIMAL(7,2),
    protein DECIMAL(6,2),
    carbohydrates DECIMAL(6,2),
    fat DECIMAL(6,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 사용자별 운동 세션
CREATE TABLE user_workout_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_name VARCHAR(200) NOT NULL,
    workout_program_id UUID REFERENCES workout_programs(id),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    total_duration_minutes INTEGER,
    exercises JSONB, -- 세션 내 운동 목록과 세트 정보
    is_completed BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 사용자별 프로그램 즐겨찾기
CREATE TABLE user_program_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    workout_program_id UUID NOT NULL REFERENCES workout_programs(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, workout_program_id)
);

-- 프로그램 평점
CREATE TABLE program_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    workout_program_id UUID NOT NULL REFERENCES workout_programs(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, workout_program_id)
);

-- 동기화 추적 테이블
CREATE TABLE sync_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(20) NOT NULL CHECK (operation IN ('insert', 'update', 'delete')),
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    client_timestamp TIMESTAMP WITH TIME ZONE,
    conflict_resolved BOOLEAN DEFAULT false
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_user_exercises_user_date ON user_exercises(user_id, exercise_date);
CREATE INDEX idx_user_meal_entries_user_date ON user_meal_entries(user_id, entry_date);
CREATE INDEX idx_user_workout_sessions_user ON user_workout_sessions(user_id, start_time);
CREATE INDEX idx_workout_programs_type_level ON workout_programs(program_type, difficulty_level);
CREATE INDEX idx_workout_programs_rating ON workout_programs(rating DESC, is_popular DESC);
CREATE INDEX idx_food_items_name ON food_items USING gin(to_tsvector('english', name));
CREATE INDEX idx_sync_records_user_table ON sync_records(user_id, table_name, synced_at);

-- 트리거 함수: updated_at 자동 갱신
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 적용
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workout_programs_updated_at BEFORE UPDATE ON workout_programs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_exercises_updated_at BEFORE UPDATE ON user_exercises FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_food_items_updated_at BEFORE UPDATE ON food_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_meal_entries_updated_at BEFORE UPDATE ON user_meal_entries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_workout_sessions_updated_at BEFORE UPDATE ON user_workout_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 샘플 운동 프로그램 데이터 삽입
INSERT INTO workout_programs (name, creator, description, duration_weeks, difficulty_level, program_type, workouts_per_week, equipment_needed, tags, rating, is_popular, is_public) VALUES 
(
    'StrongLifts 5x5',
    'Mehdi Hadim',
    '초보자를 위한 가장 인기 있는 근력 운동 프로그램입니다. 간단하고 효과적이며 근력과 근육량 증가가 입증된 프로그램입니다.',
    12,
    'beginner',
    'strength',
    3,
    '["바벨", "웨이트 플레이트", "스쿼트 랙", "벤치"]',
    '["초급", "근력", "복합운동"]',
    4.8,
    true,
    true
),
(
    'Push Pull Legs',
    'Jeff Nippard',
    '푸시 근육(가슴, 어깨, 삼두), 풀 근육(등, 이두), 다리로 나눈 6일 분할 운동입니다. 중급자부터 고급자까지 적합합니다.',
    8,
    'intermediate',
    'hypertrophy',
    6,
    '["바벨", "덤벨", "케이블 머신", "풀업바"]',
    '["중급", "근비대", "분할운동"]',
    4.6,
    true,
    true
); 