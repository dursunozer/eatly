import 'dart:async';
import 'dart:io';

import 'package:eatly/core/services/powersync_service.dart';

import 'photo_service.dart';

class UploaderService {
  UploaderService._();
  static final UploaderService instance = UploaderService._();

  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      syncOnce();
    });
    // İlk çalıştırma
    syncOnce();
  }

  Future<void> syncOnce() async {
    final db = AppPowerSync.instance.db;
    final rows = await db.getAll(
      'select id, local_path from local_photos where is_synced = 0 order by taken_at asc',
    );
    for (final r in rows) {
      final String id = r['id'] as String;
      final String localPath = r['local_path'] as String;
      try {
        final file = File(localPath);
        if (!await file.exists()) {
          // Dosya yoksa kaydı temizle
          await db.execute('delete from local_photos where id = ?', [id]);
          continue;
        }
        final bytes = await file.readAsBytes();
        final remotePath = await PhotoService.saveUserMealPhoto(bytes: bytes);
        await db.execute(
          'update local_photos set is_synced = 1, remote_path = ? where id = ?',
          [remotePath, id],
        );
      } catch (_) {
        // Sessizce geç, bir sonraki döngüde yeniden dene
      }
    }
  }
}


