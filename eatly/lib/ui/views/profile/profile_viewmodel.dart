import 'dart:typed_data';
import 'dart:async';
import 'package:stacked/stacked.dart';
import '../../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';

class ProfileViewModel extends BaseViewModel {
  String? name;
  int? age;
  double? weight;
  double? height;
  String? gender;
  double? waistCm;
  double? hipCm;
  String? email;
  String? avatarUrl;

  Future<void> init() async {
    setBusy(true);
    try {
      final uid = AuthService.currentUserId;
      if (uid == null) return;
      Map<String, dynamic>? profile = await ProfileService.fetchProfile(
        uid,
      ).timeout(const Duration(seconds: 8));
      if (profile != null) {
        name = (profile['display_name'] as String?) ?? name;
        final num? ageNum = profile['age'] as num?;
        final num? weightNum = profile['weight'] as num?;
        final num? heightNum = profile['height'] as num?;
        final num? waistNum = profile['waist_cm'] as num?;
        final num? hipNum = profile['hip_cm'] as num?;
        age = ageNum?.toInt();
        weight = weightNum?.toDouble();
        height = heightNum?.toDouble();
        waistCm = waistNum?.toDouble();
        hipCm = hipNum?.toDouble();
        gender = (profile['gender'] as String?) ?? gender;
        avatarUrl = profile['avatar_url'] as String?;
      } else {
        // Profil yoksa oluştur ve tekrar çek
        // Eğer auth.user_metadata'da kayıt sırasında toplanan bilgiler varsa
        // onları profili seedlemek için kullanalım
        final meta = Supabase.instance.client.auth.currentUser?.userMetadata ?? const {};
        await ProfileService.upsertProfile(
          uid: uid,
          displayName: meta['display_name'] as String?,
          age: (meta['age'] as num?)?.toInt(),
          weight: (meta['weight'] as num?)?.toDouble(),
          height: (meta['height'] as num?)?.toDouble(),
          gender: meta['gender'] as String?,
          waistCm: (meta['waist_cm'] as num?)?.toDouble(),
          hipCm: (meta['hip_cm'] as num?)?.toDouble(),
        );
        profile = await ProfileService.fetchProfile(
          uid,
        ).timeout(const Duration(seconds: 8));
        if (profile != null) {
          name = (profile['display_name'] as String?) ?? name;
          final num? ageNum = profile['age'] as num?;
          final num? weightNum = profile['weight'] as num?;
          final num? heightNum = profile['height'] as num?;
          final num? waistNum = profile['waist_cm'] as num?;
          final num? hipNum = profile['hip_cm'] as num?;
          age = ageNum?.toInt();
          weight = weightNum?.toDouble();
          height = heightNum?.toDouble();
          waistCm = waistNum?.toDouble();
          hipCm = hipNum?.toDouble();
          gender = (profile['gender'] as String?) ?? gender;
          avatarUrl = profile['avatar_url'] as String?;
        }
      }
      email = Supabase.instance.client.auth.currentUser?.email;
    } catch (_) {
    } finally {
      setBusy(false);
      notifyListeners();
    }
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
    final uid = AuthService.currentUserId;
    if (uid == null) return;
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
  }

  Future<void> uploadAvatar(Uint8List bytes) async {
    final uid = AuthService.currentUserId;
    if (uid == null) return;
    final url = await ProfileService.uploadAvatar(bytes: bytes, uid: uid);
    if (url != null) {
      await ProfileService.upsertProfile(uid: uid, avatarUrl: url);
      await init();
    }
  }
}
