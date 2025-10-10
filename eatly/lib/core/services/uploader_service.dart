import 'dart:async';
import 'dart:io';

import 'package:eatly/core/services/powersync_service.dart';
import '../../app/app.locator.dart';
import 'photo_service.dart';

class UploaderService {
  UploaderService._();
  static final UploaderService instance = UploaderService._();

  Timer? _timer;
  final PhotoService _photoService = PhotoService();

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      syncOnce();
    });
    // İlk çalıştırma
    syncOnce();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> syncOnce() async {
    final db = AppPowerSync.instance.db;
    try {
      // Tek seferlik seçim için getAll kullanılır
      final List<Map<String, Object?>> photos = await db.getAll('select * from local_photos where is_synced = 0');
      if (photos.isEmpty) return;
      
      print('🔼 [Uploader] ${photos.length} adet senkronize edilmemiş fotoğraf bulundu. İşleniyor...');
      
      for (final photo in photos) {
        try {
          // 1) Dosyanın varlığını kontrol et
          final file = File(photo['local_path'] as String);
          if (!await file.exists()) {
            // Dosya yoksa, bu kaydı atla ve senkronize edilmiş say
            await db.execute('update local_photos set is_synced = 1 where id = ?', [photo['id']]);
            continue;
          }

          // 2) Supabase'e yükle
          print('🔼 [Uploader] Supabase\'e yükleniyor: ${photo['local_path']}');
          final bytes = await file.readAsBytes();
          final String remotePath = await _photoService.saveUserMealPhotoV2(
            bytes: bytes,
            localId: photo['id'] as String,
          );
          
          // 3) Başarılı olursa PowerSync'te güncelle
          await db.execute(
            'update local_photos set is_synced = 1, remote_path = ? where id = ?',
            [remotePath, photo['id']],
          );
          print('✅ [Uploader] Senkronizasyon başarılı: ${photo['id']}');
        } catch (e) {
          print('❌ [Uploader] Bir fotoğraf için senkronizasyon hatası: $e. Sonraki fotoğrafa geçiliyor.');
        }
      }
    } catch (e) {
      print('❌ [Uploader] Genel senkronizasyon hatası: $e');
    }
  }
}


