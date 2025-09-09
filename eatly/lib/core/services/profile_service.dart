import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  ProfileService._();
  static final _client = Supabase.instance.client;

  static Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    final res = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    return (res is Map<String, dynamic>) ? res : null;
  }

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
  }) async {
    final sessionUid = _client.auth.currentUser?.id ?? _client.auth.currentSession?.user.id;
    if (sessionUid == null) {
      // RLS nedeniyle anonim istekle INSERT/UPSERT yapamayız; önce auth gerekir
      throw StateError('Authenticated session is required before upserting profile.');
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
      'updated_at': DateTime.now().toIso8601String(),
    };
    // İlk kullanıcı oluşturma anında auth.users satırı henüz görünür olmayabilir
    // (özellikle yeni projelerde). FK 23503 hatasını kısa bir süre toleransla tekrar dene.
    PostgrestException? lastFkErr;
    for (int attempt = 0; attempt < 6; attempt++) {
      try {
        await _client.from('profiles').upsert(data, onConflict: 'id');
        lastFkErr = null;
        break;
      } on PostgrestException catch (e) {
        if (e.code == '23503' || (e.message ?? '').toLowerCase().contains('foreign key')) {
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

  static Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String uid,
  }) async {
    final path = 'avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('user-photos').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
    final url = _client.storage.from('user-photos').getPublicUrl(path);
    return url;
  }
}
