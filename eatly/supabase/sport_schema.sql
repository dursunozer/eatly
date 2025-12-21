-- =====================================================
-- SPOR MODÜLÜ VERİTABANI ŞEMASI
-- =====================================================

-- 1. SPOR AKTİVİTELERİ TABLOSU
-- Kullanıcının yaptığı tüm spor aktivitelerini saklar
CREATE TABLE IF NOT EXISTS sport_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    activity_type TEXT NOT NULL DEFAULT 'other', -- running, walking, cycling, swimming, workout, yoga, other
    duration_minutes INTEGER NOT NULL DEFAULT 0,
    calories_burned FLOAT8 DEFAULT 0,
    distance_km FLOAT8, -- Koşu, yürüyüş, bisiklet için
    steps INTEGER, -- Adım sayısı
    heart_rate_avg INTEGER, -- Ortalama kalp atışı
    notes TEXT,
    source TEXT DEFAULT 'manual', -- manual, health_connect, healthkit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    activity_date DATE DEFAULT CURRENT_DATE
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_sport_activities_user_date ON sport_activities(user_id, activity_date);
CREATE INDEX IF NOT EXISTS idx_sport_activities_type ON sport_activities(activity_type);

-- 2. SU TAKİBİ TABLOSU
-- Günlük su tüketimini takip eder
CREATE TABLE IF NOT EXISTS water_intake (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    amount_ml INTEGER NOT NULL, -- mililitre cinsinden
    intake_date DATE DEFAULT CURRENT_DATE,
    intake_time TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_water_intake_user_date ON water_intake(user_id, intake_date);

-- 3. SU HEDEFLERİ TABLOSU
-- Kullanıcının günlük su hedefini saklar
CREATE TABLE IF NOT EXISTS water_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    daily_goal_ml INTEGER NOT NULL DEFAULT 2000, -- Varsayılan 2 litre
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 4. ANTRENMAN PROGRAMLARI TABLOSU
-- Hazır antrenman programları
CREATE TABLE IF NOT EXISTS workout_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    name_tr TEXT NOT NULL, -- Türkçe isim
    description TEXT,
    description_tr TEXT, -- Türkçe açıklama
    difficulty_level TEXT NOT NULL DEFAULT 'beginner', -- beginner, intermediate, advanced
    duration_weeks INTEGER NOT NULL DEFAULT 4,
    category TEXT NOT NULL DEFAULT 'general', -- weight_loss, muscle_gain, flexibility, cardio, general
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. ANTRENMAN EGZERSİZLERİ TABLOSU
-- Her program içindeki egzersizler
CREATE TABLE IF NOT EXISTS workout_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id UUID REFERENCES workout_programs(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    name_tr TEXT NOT NULL,
    description TEXT,
    description_tr TEXT,
    muscle_group TEXT, -- chest, back, legs, arms, core, full_body
    sets INTEGER DEFAULT 3,
    reps INTEGER DEFAULT 10,
    duration_seconds INTEGER, -- Plank gibi süre bazlı egzersizler için
    rest_seconds INTEGER DEFAULT 60,
    day_of_week INTEGER, -- 1-7 (Pazartesi-Pazar)
    week_number INTEGER DEFAULT 1,
    order_index INTEGER DEFAULT 0,
    video_url TEXT,
    image_url TEXT,
    calories_per_set FLOAT8 DEFAULT 5,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for program exercises
CREATE INDEX IF NOT EXISTS idx_workout_exercises_program ON workout_exercises(program_id);

-- 6. KULLANICI ANTRENMAN İLERLEMESİ
-- Kullanıcının programa katılımı ve ilerlemesi
CREATE TABLE IF NOT EXISTS user_workout_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    program_id UUID REFERENCES workout_programs(id) ON DELETE CASCADE,
    exercise_id UUID REFERENCES workout_exercises(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    sets_completed INTEGER DEFAULT 0,
    reps_completed INTEGER DEFAULT 0,
    duration_seconds INTEGER DEFAULT 0,
    notes TEXT
);

-- Index for user progress
CREATE INDEX IF NOT EXISTS idx_user_workout_progress_user ON user_workout_progress(user_id, program_id);

-- 7. ROZETLER/BAŞARIMLAR TABLOSU
-- Tüm mevcut rozetler
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL, -- steps_10k, workout_7_streak, water_week, etc.
    name TEXT NOT NULL,
    name_tr TEXT NOT NULL,
    description TEXT,
    description_tr TEXT,
    category TEXT NOT NULL DEFAULT 'general', -- steps, workout, water, calories, streak
    icon_name TEXT DEFAULT 'emoji_events', -- Material icon name
    requirement_value INTEGER NOT NULL, -- Hedefe ulaşmak için gereken değer
    requirement_type TEXT NOT NULL, -- total, daily, streak
    points INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. KULLANICI ROZETLERİ TABLOSU
-- Kullanıcının kazandığı rozetler
CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    progress_value INTEGER DEFAULT 0, -- Mevcut ilerleme
    UNIQUE(user_id, achievement_id)
);

-- Index for user achievements
CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON user_achievements(user_id);

-- 9. GÜNLÜK ADIM VERİSİ TABLOSU
-- Health Connect/HealthKit'ten gelen adım verisi
CREATE TABLE IF NOT EXISTS daily_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    step_count INTEGER NOT NULL DEFAULT 0,
    step_date DATE DEFAULT CURRENT_DATE,
    calories_burned FLOAT8 DEFAULT 0,
    distance_km FLOAT8 DEFAULT 0,
    source TEXT DEFAULT 'manual', -- manual, health_connect, healthkit
    synced_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, step_date)
);

-- Index for daily steps
CREATE INDEX IF NOT EXISTS idx_daily_steps_user_date ON daily_steps(user_id, step_date);

-- 10. SPOR HEDEFLERİ TABLOSU
-- Kullanıcının spor hedefleri
CREATE TABLE IF NOT EXISTS sport_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    daily_step_goal INTEGER DEFAULT 10000,
    daily_calorie_burn_goal FLOAT8 DEFAULT 500,
    weekly_workout_goal INTEGER DEFAULT 3, -- Haftalık antrenman sayısı
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- =====================================================
-- BAŞLANGIÇ VERİLERİ (SEED DATA)
-- =====================================================

-- Hazır Rozetler
INSERT INTO achievements (code, name, name_tr, description, description_tr, category, icon_name, requirement_value, requirement_type, points) VALUES
-- Adım Rozetleri
('steps_10k', 'First 10K', 'İlk 10K', 'Walk 10,000 steps in a day', 'Bir günde 10.000 adım at', 'steps', 'directions_walk', 10000, 'daily', 10),
('steps_50k', 'Step Master', 'Adım Ustası', 'Walk 50,000 steps total', 'Toplam 50.000 adım at', 'steps', 'directions_walk', 50000, 'total', 25),
('steps_100k', 'Step Legend', 'Adım Efsanesi', 'Walk 100,000 steps total', 'Toplam 100.000 adım at', 'steps', 'directions_walk', 100000, 'total', 50),
('steps_500k', 'Marathon Walker', 'Maraton Yürüyüşçüsü', 'Walk 500,000 steps total', 'Toplam 500.000 adım at', 'steps', 'directions_walk', 500000, 'total', 100),

-- Antrenman Rozetleri
('workout_first', 'First Workout', 'İlk Antrenman', 'Complete your first workout', 'İlk antrenmanını tamamla', 'workout', 'fitness_center', 1, 'total', 5),
('workout_7_streak', 'Week Warrior', 'Hafta Savaşçısı', 'Work out 7 days in a row', '7 gün üst üste antrenman yap', 'workout', 'local_fire_department', 7, 'streak', 30),
('workout_30_streak', 'Iron Will', 'Demir İrade', 'Work out 30 days in a row', '30 gün üst üste antrenman yap', 'workout', 'military_tech', 30, 'streak', 100),
('workout_100', 'Century Club', 'Yüzler Kulübü', 'Complete 100 workouts', '100 antrenman tamamla', 'workout', 'emoji_events', 100, 'total', 75),

-- Su Rozetleri
('water_daily', 'Hydrated', 'Nemlendi', 'Reach daily water goal', 'Günlük su hedefine ulaş', 'water', 'water_drop', 1, 'daily', 5),
('water_week', 'Water Week', 'Su Haftası', 'Reach water goal 7 days in a row', '7 gün üst üste su hedefine ulaş', 'water', 'waves', 7, 'streak', 25),
('water_month', 'Hydration Master', 'Hidrasyon Ustası', 'Reach water goal 30 days in a row', '30 gün üst üste su hedefine ulaş', 'water', 'pool', 30, 'streak', 75),

-- Kalori Rozetleri
('calories_500', 'Calorie Crusher', 'Kalori Ezici', 'Burn 500 calories in a day', 'Bir günde 500 kalori yak', 'calories', 'local_fire_department', 500, 'daily', 10),
('calories_1000', 'Inferno', 'Cehennem Ateşi', 'Burn 1000 calories in a day', 'Bir günde 1000 kalori yak', 'calories', 'whatshot', 1000, 'daily', 25),
('calories_10k', 'Fat Burner', 'Yağ Yakıcı', 'Burn 10,000 total calories', 'Toplam 10.000 kalori yak', 'calories', 'local_fire_department', 10000, 'total', 50)
ON CONFLICT (code) DO NOTHING;

-- Hazır Antrenman Programları
INSERT INTO workout_programs (id, name, name_tr, description, description_tr, difficulty_level, duration_weeks, category) VALUES
('11111111-1111-1111-1111-111111111111', 'Beginner Basics', 'Başlangıç Temelleri', 'Perfect for those just starting their fitness journey', 'Fitness yolculuğuna yeni başlayanlar için mükemmel', 'beginner', 4, 'general'),
('22222222-2222-2222-2222-222222222222', 'Fat Burn HIIT', 'Yağ Yakıcı HIIT', 'High-intensity interval training for maximum fat burn', 'Maksimum yağ yakımı için yüksek yoğunluklu interval antrenmanı', 'intermediate', 6, 'weight_loss'),
('33333333-3333-3333-3333-333333333333', 'Muscle Builder', 'Kas Geliştirici', 'Build strength and muscle mass', 'Güç ve kas kütlesi oluştur', 'advanced', 8, 'muscle_gain'),
('44444444-4444-4444-4444-444444444444', 'Flexibility Flow', 'Esneklik Akışı', 'Improve flexibility and reduce stress with yoga', 'Yoga ile esnekliği artır ve stresi azalt', 'beginner', 4, 'flexibility')
ON CONFLICT DO NOTHING;

-- Başlangıç Programı Egzersizleri
INSERT INTO workout_exercises (program_id, name, name_tr, description_tr, muscle_group, sets, reps, rest_seconds, day_of_week, week_number, order_index, calories_per_set) VALUES
-- Hafta 1 - Pazartesi
('11111111-1111-1111-1111-111111111111', 'Jumping Jacks', 'Jumping Jack', 'Kolları ve bacakları açarak zıplama', 'full_body', 3, 20, 30, 1, 1, 1, 8),
('11111111-1111-1111-1111-111111111111', 'Bodyweight Squats', 'Squat', 'Vücut ağırlığıyla çömelme', 'legs', 3, 15, 45, 1, 1, 2, 6),
('11111111-1111-1111-1111-111111111111', 'Push-ups (Knee)', 'Diz Şınavı', 'Dizler yerde şınav', 'chest', 3, 10, 60, 1, 1, 3, 5),
('11111111-1111-1111-1111-111111111111', 'Plank', 'Plank', 'Karın kaslarını çalıştıran duruş', 'core', 3, 1, 45, 1, 1, 4, 4),
-- Hafta 1 - Çarşamba
('11111111-1111-1111-1111-111111111111', 'High Knees', 'Yüksek Diz', 'Yerinde koşarak dizleri yukarı kaldırma', 'full_body', 3, 20, 30, 3, 1, 1, 10),
('11111111-1111-1111-1111-111111111111', 'Lunges', 'Lunge', 'İleriye adım atarak çömelme', 'legs', 3, 12, 45, 3, 1, 2, 7),
('11111111-1111-1111-1111-111111111111', 'Mountain Climbers', 'Dağcı', 'Plank pozisyonunda dizleri çekme', 'core', 3, 15, 45, 3, 1, 3, 8),
-- Hafta 1 - Cuma
('11111111-1111-1111-1111-111111111111', 'Burpees', 'Burpee', 'Tam vücut hareket kombinasyonu', 'full_body', 3, 8, 60, 5, 1, 1, 12),
('11111111-1111-1111-1111-111111111111', 'Glute Bridge', 'Kalça Köprüsü', 'Sırt üstü yatarak kalçayı kaldırma', 'legs', 3, 15, 45, 5, 1, 2, 5),
('11111111-1111-1111-1111-111111111111', 'Superman', 'Süpermen', 'Yüzüstü yatarak el ve ayakları kaldırma', 'back', 3, 12, 45, 5, 1, 3, 4);

-- HIIT Programı Egzersizleri
INSERT INTO workout_exercises (program_id, name, name_tr, description_tr, muscle_group, sets, reps, duration_seconds, rest_seconds, day_of_week, week_number, order_index, calories_per_set) VALUES
-- Hafta 1 - Pazartesi
('22222222-2222-2222-2222-222222222222', 'Sprint in Place', 'Yerinde Sprint', 'Maksimum hızda yerinde koşu', 'full_body', 4, 1, 30, 30, 1, 1, 1, 15),
('22222222-2222-2222-2222-222222222222', 'Jump Squats', 'Zıplayan Squat', 'Squat yaparak zıplama', 'legs', 4, 15, NULL, 30, 1, 1, 2, 12),
('22222222-2222-2222-2222-222222222222', 'Burpees', 'Burpee', 'Tam vücut patlayıcı hareket', 'full_body', 4, 10, NULL, 30, 1, 1, 3, 15),
('22222222-2222-2222-2222-222222222222', 'Mountain Climbers', 'Dağcı', 'Hızlı dağcı hareketi', 'core', 4, 1, 30, 30, 1, 1, 4, 12);

-- RLS Politikaları
ALTER TABLE sport_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_intake ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_workout_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE sport_goals ENABLE ROW LEVEL SECURITY;

-- Kullanıcı sadece kendi verisini görebilir
CREATE POLICY "Users can view own sport_activities" ON sport_activities FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own sport_activities" ON sport_activities FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own sport_activities" ON sport_activities FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own sport_activities" ON sport_activities FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own water_intake" ON water_intake FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own water_intake" ON water_intake FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own water_intake" ON water_intake FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own water_intake" ON water_intake FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own water_goals" ON water_goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own water_goals" ON water_goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own water_goals" ON water_goals FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own workout_progress" ON user_workout_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own workout_progress" ON user_workout_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own workout_progress" ON user_workout_progress FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own achievements" ON user_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own achievements" ON user_achievements FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own achievements" ON user_achievements FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own daily_steps" ON daily_steps FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own daily_steps" ON daily_steps FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own daily_steps" ON daily_steps FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own sport_goals" ON sport_goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own sport_goals" ON sport_goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own sport_goals" ON sport_goals FOR UPDATE USING (auth.uid() = user_id);

-- Herkes programları ve rozetleri görebilir (public data)
CREATE POLICY "Anyone can view workout_programs" ON workout_programs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Anyone can view workout_exercises" ON workout_exercises FOR SELECT TO authenticated USING (true);
CREATE POLICY "Anyone can view achievements" ON achievements FOR SELECT TO authenticated USING (true);

