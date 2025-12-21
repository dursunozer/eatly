import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'nutrition_calculator_service.dart';

class ProfileService {
  ProfileService._();
  // Her çağrıda güncel Supabase client'ını al (auth state değişikliklerini yakala)
  static SupabaseClient get _client => Supabase.instance.client;

  /// Kullanıcı profili getir
  static Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    final res = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    return (res is Map<String, dynamic>) ? res : null;
  }

  /// Mevcut kullanıcının profilini UserProfile olarak getir
  static Future<UserProfile?> getCurrentUserProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    
    final data = await fetchProfile(uid);
    if (data == null) return null;
    
    return UserProfile.fromJson(data);
  }

  /// Onboarding tamamlandı mı kontrol et
  static Future<bool> isOnboardingCompleted() async {
    final profile = await getCurrentUserProfile();
    return profile?.onboardingCompleted ?? false;
  }

  /// Temel profil bilgilerini güncelle
  static Future<void> upsertProfile({
    required String uid,
    String? displayName,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? avatarUrl,
    double? waistCm,
    double? hipCm,
    String? timezone,
    String? activityLevel,
  }) async {
    final sessionUid =
        _client.auth.currentUser?.id ?? _client.auth.currentSession?.user.id;
    if (sessionUid == null) {
      throw StateError(
        'Authenticated session is required before upserting profile.',
      );
    }
    final data = <String, dynamic>{
      'id': sessionUid,
      if (displayName != null) 'display_name': displayName,
      if (age != null) 'age': age,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (gender != null) 'gender': gender,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (waistCm != null) 'waist_cm': waistCm,
      if (hipCm != null) 'hip_cm': hipCm,
      if (timezone != null) 'timezone': timezone,
      if (activityLevel != null) 'activity_level': activityLevel,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _retryUpsert(data);
  }

  /// Onboarding verilerini kaydet ve hedefleri hesapla
  static Future<void> saveOnboardingData({
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
    required String goal,
    String? displayName,
  }) async {
    final user = _client.auth.currentUser;
    final sessionUid = user?.id;
    if (sessionUid == null) {
      throw StateError(
        'Authenticated session is required before saving onboarding data.',
      );
    }

    // display_name belirleme
    String finalDisplayName = displayName ?? 'Kullanıcı';
    if (displayName == null || displayName.isEmpty) {
      try {
        final existingProfile = await _client
            .from('profiles')
            .select('display_name')
            .eq('id', sessionUid)
            .maybeSingle();
        
        if (existingProfile != null && existingProfile['display_name'] != null) {
          finalDisplayName = existingProfile['display_name'] as String;
        } else {
          // E-posta veya metadata'dan al
          finalDisplayName = user?.userMetadata?['display_name'] as String? ??
              user?.userMetadata?['full_name'] as String? ??
              user?.email?.split('@').first ??
              'Kullanıcı';
        }
      } catch (_) {
        // Hata durumunda varsayılan değeri kullan
      }
    }

    // Hedefleri hesapla
    final isMale = gender.toLowerCase() == 'erkek' || gender.toLowerCase() == 'male';
    final targets = NutritionCalculatorService.calculateAllTargets(
      weight: weight,
      height: height,
      age: age,
      isMale: isMale,
      activityLevel: activityLevel,
      goal: goal,
    );

    final data = <String, dynamic>{
      'id': sessionUid,
      'display_name': finalDisplayName,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activity_level': activityLevel,
      'goal': goal,
      'target_calories': targets.targetCalories,
      'target_protein': targets.targetProtein,
      'target_carbs': targets.targetCarbs,
      'target_fat': targets.targetFat,
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _retryUpsert(data);
  }

  /// Sadece beslenme hedeflerini güncelle
  static Future<void> updateNutritionTargets({
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
  }) async {
    final sessionUid = _client.auth.currentUser?.id;
    if (sessionUid == null) {
      throw StateError(
        'Authenticated session is required before updating targets.',
      );
    }

    // display_name NOT NULL constraint için mevcut değeri al
    final profile = await getCurrentUserProfile();
    final displayName = profile?.fullName ?? 
        _client.auth.currentUser?.email?.split('@').first ?? 
        'Kullanıcı';

    final data = <String, dynamic>{
      'id': sessionUid,
      'display_name': displayName,
      'target_calories': targetCalories,
      'target_protein': targetProtein,
      'target_carbs': targetCarbs,
      'target_fat': targetFat,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _retryUpsert(data);
  }

  /// Hedef ve aktivite bilgilerini güncelle (profil sayfasından)
  static Future<void> updateGoalAndActivity({
    required String goal,
    required String activityLevel,
  }) async {
    final profile = await getCurrentUserProfile();
    if (profile == null) {
      throw StateError('Profile not found');
    }

    // Yeni hedefleri hesapla
    final isMale = (profile.gender?.toLowerCase() ?? 'erkek') == 'erkek';
    final targets = NutritionCalculatorService.calculateAllTargets(
      weight: profile.weight ?? 70,
      height: profile.height ?? 170,
      age: profile.age ?? 25,
      isMale: isMale,
      activityLevel: activityLevel,
      goal: goal,
    );

    final sessionUid = _client.auth.currentUser?.id;
    if (sessionUid == null) return;

    // display_name NOT NULL constraint için mevcut değeri al
    final displayName = profile.fullName ?? 
        _client.auth.currentUser?.email?.split('@').first ?? 
        'Kullanıcı';

    final data = <String, dynamic>{
      'id': sessionUid,
      'display_name': displayName,
      'activity_level': activityLevel,
      'goal': goal,
      'target_calories': targets.targetCalories,
      'target_protein': targets.targetProtein,
      'target_carbs': targets.targetCarbs,
      'target_fat': targets.targetFat,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _retryUpsert(data);
  }

  /// Boy/kilo güncellendiğinde hedefleri yeniden hesapla
  static Future<void> recalculateTargetsOnBodyChange({
    required double weight,
    required double height,
  }) async {
    final profile = await getCurrentUserProfile();
    if (profile == null || !profile.onboardingCompleted) return;

    final isMale = (profile.gender?.toLowerCase() ?? 'erkek') == 'erkek';
    final targets = NutritionCalculatorService.calculateAllTargets(
      weight: weight,
      height: height,
      age: profile.age ?? 25,
      isMale: isMale,
      activityLevel: profile.activityLevel ?? NutritionCalculatorService.activityModeratelyActive,
      goal: profile.goal ?? NutritionCalculatorService.goalMaintain,
    );

    final sessionUid = _client.auth.currentUser?.id;
    if (sessionUid == null) return;

    // display_name NOT NULL constraint için mevcut değeri al
    final displayName = profile.fullName ?? 
        _client.auth.currentUser?.email?.split('@').first ?? 
        'Kullanıcı';

    final data = <String, dynamic>{
      'id': sessionUid,
      'display_name': displayName,
      'weight': weight,
      'height': height,
      'target_calories': targets.targetCalories,
      'target_protein': targets.targetProtein,
      'target_carbs': targets.targetCarbs,
      'target_fat': targets.targetFat,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _retryUpsert(data);
  }

  /// Avatar yükle
  static Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String uid,
  }) async {
    final path = 'avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage
        .from('food_images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
    String url;
    try {
      url = await _client.storage
          .from('food_images')
          .createSignedUrl(path, 3600);
    } catch (_) {
      url = _client.storage.from('food_images').getPublicUrl(path);
    }
    return url;
  }

  /// Upsert işlemini FK hatalarına karşı retry ile yap
  static Future<void> _retryUpsert(Map<String, dynamic> data) async {
    PostgrestException? lastFkErr;
    for (int attempt = 0; attempt < 6; attempt++) {
      try {
        await _client.from('profiles').upsert(data, onConflict: 'id');
        lastFkErr = null;
        break;
      } on PostgrestException catch (e) {
        if (e.code == '23503' ||
            (e.message ?? '').toLowerCase().contains('foreign key')) {
          lastFkErr = e;
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }
        rethrow;
      }
    }
    if (lastFkErr != null) {
      throw lastFkErr;
    }
  }

  /// Kullanıcının yemek fotoğraflarını sil
  static Future<void> deleteUserMealPhotos(String uid) async {
    try {
      await _client.from('meal_photos').delete().eq('user_id', uid);
    } catch (e) {
      // Tablo yoksa veya veri yoksa hata vermesin
      print('Meal photos silme hatası: $e');
    }
  }

  /// Kullanıcının spor aktivitelerini sil
  static Future<void> deleteUserActivities(String uid) async {
    try {
      await _client.from('sport_activities').delete().eq('user_id', uid);
    } catch (e) {
      // Tablo yoksa veya veri yoksa hata vermesin
      print('Aktiviteler silme hatası: $e');
    }
  }

  /// Kullanıcının profilini sil
  static Future<void> deleteProfile(String uid) async {
    await _client.from('profiles').delete().eq('id', uid);
  }
}
