import 'dart:typed_data';
import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';

class ProfileViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  
  // Kişisel bilgiler
  String? name;
  int? age;
  double? weight;
  double? height;
  String? gender;
  double? waistCm;
  double? hipCm;
  String? email;
  String? avatarUrl;
  
  // Hedefler
  String? goal;
  String? activityLevel;
  double? targetCalories;
  double? targetProtein;
  double? targetCarbs;
  double? targetFat;
  bool onboardingCompleted = false;

  // Hesaplanan değerler
  double? get bmi {
    if (height != null && height! > 0 && weight != null && weight! > 0) {
      final m = height! / 100.0;
      return weight! / (m * m);
    }
    return null;
  }

  String get bmiCategory {
    if (bmi == null) return '-';
    if (bmi! < 18.5) return 'Zayıf';
    if (bmi! < 25) return 'Normal';
    if (bmi! < 30) return 'Fazla Kilolu';
    return 'Obez';
  }

  String get goalTitle {
    switch (goal) {
      case 'lose_weight':
        return 'Kilo Vermek';
      case 'gain_weight':
        return 'Kilo Almak';
      case 'maintain':
        return 'Kilomu Korumak';
      case 'build_muscle':
        return 'Kas Kütlesi Kazanmak';
      default:
        return 'Hedef Belirlenmedi';
    }
  }

  String get activityLevelTitle {
    switch (activityLevel) {
      case 'sedentary':
        return 'Hareketsiz';
      case 'lightly_active':
        return 'Hafif Aktif';
      case 'moderately_active':
        return 'Orta Aktif';
      case 'active':
        return 'Aktif';
      case 'very_active':
        return 'Çok Aktif';
      default:
        return '-';
    }
  }

  Future<void> init() async {
    setBusy(true);
    try {
      final uid = _authService.currentUserId;
      if (uid == null) return;
      
      Map<String, dynamic>? profile = await ProfileService.fetchProfile(uid)
          .timeout(const Duration(seconds: 8));
      
      if (profile != null) {
        _parseProfile(profile);
      } else {
        // Profil yoksa oluştur
        final user = Supabase.instance.client.auth.currentUser;
        final meta = user?.userMetadata ?? const {};
        final displayName = meta['display_name'] as String? ??
            meta['full_name'] as String? ??
            user?.email?.split('@').first ??
            'Kullanıcı';
        await ProfileService.upsertProfile(
          uid: uid,
          displayName: displayName,
          age: (meta['age'] as num?)?.toInt(),
          weight: (meta['weight'] as num?)?.toDouble(),
          height: (meta['height'] as num?)?.toDouble(),
          gender: meta['gender'] as String?,
        );
        profile = await ProfileService.fetchProfile(uid)
            .timeout(const Duration(seconds: 8));
        if (profile != null) {
          _parseProfile(profile);
        }
      }
      email = Supabase.instance.client.auth.currentUser?.email;
    } catch (_) {
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void _parseProfile(Map<String, dynamic> profile) {
    name = profile['display_name'] as String?;
    age = (profile['age'] as num?)?.toInt();
    weight = (profile['weight'] as num?)?.toDouble();
    height = (profile['height'] as num?)?.toDouble();
    waistCm = (profile['waist_cm'] as num?)?.toDouble();
    hipCm = (profile['hip_cm'] as num?)?.toDouble();
    gender = profile['gender'] as String?;
    avatarUrl = profile['avatar_url'] as String?;
    goal = profile['goal'] as String?;
    activityLevel = profile['activity_level'] as String?;
    targetCalories = (profile['target_calories'] as num?)?.toDouble();
    targetProtein = (profile['target_protein'] as num?)?.toDouble();
    targetCarbs = (profile['target_carbs'] as num?)?.toDouble();
    targetFat = (profile['target_fat'] as num?)?.toDouble();
    onboardingCompleted = profile['onboarding_completed'] as bool? ?? false;
  }

  String get initials => ((name ?? '?').isNotEmpty ? (name ?? '?')[0] : '?').toUpperCase();

  Future<void> saveProfile({
    required String newName,
    required int newAge,
    required double newWeight,
    required double newHeight,
    String? newGender,
    double? newWaistCm,
    double? newHipCm,
  }) async {
    final uid = _authService.currentUserId;
    if (uid == null) return;
    setBusy(true);
    try {
      await ProfileService.upsertProfile(
        uid: uid,
        displayName: newName,
        age: newAge,
        weight: newWeight,
        height: newHeight,
        gender: newGender,
        waistCm: newWaistCm,
        hipCm: newHipCm,
      );
      await init();
    } finally {
      setBusy(false);
    }
  }

  Future<void> updatePersonalInfo({
    String? newName,
    int? newAge,
    double? newWeight,
    double? newHeight,
    String? newGender,
    String? newActivityLevel,
  }) async {
    final uid = _authService.currentUserId;
    if (uid == null) return;
    setBusy(true);
    try {
      await ProfileService.upsertProfile(
        uid: uid,
        displayName: newName ?? name ?? 'Kullanıcı',
        age: newAge ?? age,
        weight: newWeight ?? weight,
        height: newHeight ?? height,
        gender: newGender ?? gender,
        activityLevel: newActivityLevel ?? activityLevel,
      );
      await init();
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateGoalAndActivity({
    required String newGoal,
    required String newActivityLevel,
  }) async {
    final uid = _authService.currentUserId;
    if (uid == null) return;
    setBusy(true);
    try {
      await ProfileService.updateGoalAndActivity(
        goal: newGoal,
        activityLevel: newActivityLevel,
      );
      await init();
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateBodyMeasurements({
    double? newWaistCm,
    double? newHipCm,
  }) async {
    final uid = _authService.currentUserId;
    if (uid == null) return;
    setBusy(true);
    try {
      await ProfileService.upsertProfile(
        uid: uid,
        displayName: name ?? 'Kullanıcı',
        waistCm: newWaistCm ?? waistCm,
        hipCm: newHipCm ?? hipCm,
      );
      await init();
    } finally {
      setBusy(false);
    }
  }

  Future<void> uploadAvatar(Uint8List bytes) async {
    final uid = _authService.currentUserId;
    if (uid == null) return;
    final url = await ProfileService.uploadAvatar(bytes: bytes, uid: uid);
    if (url != null) {
      // Mevcut display_name'i de gönder (NOT NULL constraint)
      await ProfileService.upsertProfile(
        uid: uid, 
        avatarUrl: url,
        displayName: name ?? 'Kullanıcı',
      );
      await init();
    }
  }

  Future<void> signOut() async {
    setBusy(true);
    try {
      await _authService.signOut();
      _navigationService.clearStackAndShow(Routes.welcomeView);
    } finally {
      setBusy(false);
    }
  }

  String? _passwordResetError;
  String? get passwordResetError => _passwordResetError;
  bool _passwordResetSuccess = false;
  bool get passwordResetSuccess => _passwordResetSuccess;

  Future<bool> sendPasswordResetEmail() async {
    if (email == null) return false;
    _passwordResetError = null;
    _passwordResetSuccess = false;
    setBusy(true);
    try {
      await _authService.sendPasswordResetEmail(email!);
      _passwordResetSuccess = true;
      return true;
    } catch (e) {
      _passwordResetError = e.toString();
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  String? _deleteAccountError;
  String? get deleteAccountError => _deleteAccountError;

  Future<bool> deleteAccount() async {
    final uid = _authService.currentUserId;
    if (uid == null) return false;
    
    _deleteAccountError = null;
    setBusy(true);
    try {
      // 1. Kullanıcının yemek fotoğraflarını sil
      await ProfileService.deleteUserMealPhotos(uid);
      
      // 2. Kullanıcının spor aktivitelerini sil
      await ProfileService.deleteUserActivities(uid);
      
      // 3. Kullanıcının profilini sil
      await ProfileService.deleteProfile(uid);
      
      // 4. Çıkış yap
      await _authService.signOut();
      
      // 5. Welcome ekranına yönlendir
      _navigationService.clearStackAndShow(Routes.welcomeView);
      
      return true;
    } catch (e) {
      _deleteAccountError = e.toString();
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
}
