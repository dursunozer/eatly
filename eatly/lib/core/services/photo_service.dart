import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _bucket = 'food_images';
  String get bucket => _bucket;

  Future<String> saveUserMealPhoto({
    required Uint8List bytes,
    DateTime? takenAt,
    List<Map<String, dynamic>>? labels,
    List<Map<String, dynamic>>? objects,
    Map<String, dynamic>? nutrition,
  }) async {
    final String? uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }

    final DateTime now = DateTime.now().toUtc();
    final String path = 'meals/$uid/${now.millisecondsSinceEpoch}.jpg';

    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
        );


    final Map<String, dynamic> row = {
      'user_id': uid,
      'storage_path': path,
      'taken_at': ((takenAt ?? now).toUtc()).toIso8601String(),
      'size_bytes': bytes.length,
      if (labels != null) 'labels': labels,
      if (objects != null) 'objects': objects,
      if (nutrition != null) 'nutrition': nutrition,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'deleted': false,
    };

    await _client.from('user_photos').insert(row);

    // Güvenlik: public URL kaydı tutmuyoruz; gerektiğinde imzalı URL üretilir.

    return path;
  }

  Future<List<String>> fetchTodayPhotoUrls() async {
    final String? uid = _client.auth.currentUser?.id;
    if (uid == null) return <String>[];
    // Sunucu tarafında kullanıcı saat dilimine göre filtreleyen view kullan
    final List<dynamic> res = await _client
        .from('user_photos_today')
        .select('storage_path,taken_at')
        .eq('user_id', uid)
        .order('taken_at', ascending: false);

    final storage = _client.storage.from(_bucket);
    final List<String> paths =
        res.map((e) => e['storage_path'] as String).toList();

    // Yalnızca imzalı URL üretelim (1 saat geçerli). Başarısız olanları atla.
    final List<String> urls = [];
    for (final path in paths) {
      try {
        final signed = await storage.createSignedUrl(path, 3600);
        urls.add(signed);
      } catch (_) {
        // İmzalı URL üretilemezse bu öğeyi atlıyoruz.
      }
    }
    return urls;
  }

  Future<bool> existsUserPhoto({required String storagePath}) async {
    final String? uid = _client.auth.currentUser?.id;
    if (uid == null) return false;
    final List<dynamic> res = await _client
        .from('user_photos')
        .select('storage_path')
        .eq('user_id', uid)
        .eq('storage_path', storagePath)
        .limit(1);
    return res.isNotEmpty;
  }
}


