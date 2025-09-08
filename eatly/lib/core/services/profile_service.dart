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
    final sessionUid = _client.auth.currentUser?.id ?? uid;
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
    await _client.from('profiles').upsert(data, onConflict: 'id');
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
