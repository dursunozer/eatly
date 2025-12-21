-- Profiles tablosuna onboarding için gerekli yeni alanlar ekleniyor
-- Bu SQL'i Supabase Dashboard > SQL Editor'de çalıştırın

-- Hedef alanı: kilo verme, alma, koruma, kas kütlesi
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS goal text;

-- Aktivite seviyesi
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS activity_level text;

-- Hesaplanan hedefler
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS target_calories float8;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS target_protein float8;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS target_carbs float8;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS target_fat float8;

-- Onboarding tamamlandı mı?
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS onboarding_completed bool DEFAULT false;

-- Goal için check constraint (opsiyonel - değerleri sınırlamak için)
-- ALTER TABLE profiles 
-- ADD CONSTRAINT valid_goal CHECK (goal IN ('lose_weight', 'gain_weight', 'maintain', 'build_muscle'));

-- Activity level için check constraint (opsiyonel)
-- ALTER TABLE profiles 
-- ADD CONSTRAINT valid_activity_level CHECK (activity_level IN ('sedentary', 'lightly_active', 'moderately_active', 'active', 'very_active'));

-- Yorum: Constraint'ler opsiyoneldir, uygulama tarafında da kontrol edilebilir

