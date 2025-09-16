import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'powersync_service.dart';
import 'photo_service.dart';
import '../../app/app.locator.dart';

class DailyCleanupService {
  DailyCleanupService._();
  static final DailyCleanupService instance = DailyCleanupService._();

  Timer? _timer;
  DateTime? _lastRunDay;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => _maybeRun());
    _maybeRun();
  }

  Future<void> _maybeRun() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_lastRunDay == today) return;
    if (now.hour != 0) return; // 00.xx saatlerinde çalıştır
    _lastRunDay = today;
    await _runCleanup();
  }

  Future<void> _runCleanup() async {
    // 1) Yerel dosyaları (local_photos) dünden kalanları sil
    if (!kIsWeb) {
      try {
        final rows = await AppPowerSync.instance.db.getAll(
          'select id, local_path, taken_at from local_photos where taken_at < ?',
          [DateTime.now().toIso8601String().split('T').first],
        );
        for (final r in rows) {
          final String id = r['id'] as String;
          final String path = r['local_path'] as String;
          try {
            final f = File(path);
            if (await f.exists()) {
              await f.delete();
            }
          } catch (_) {}
          await AppPowerSync.instance.db.execute(
              'delete from local_photos where id = ?', [id]);
        }
      } catch (_) {}
    }

    // 2) Supabase tarafında dünden eski user_photos kayıtlarını sil (storage + tablo)
    try {
      final String? uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);
      final List<dynamic> res = await Supabase.instance.client
          .from('user_photos')
          .select('id, storage_path, taken_at')
          .eq('user_id', uid)
          .lt('taken_at', startOfDay.toIso8601String());
      for (final r in res) {
        final String id = r['id'] as String;
        final String storagePath = r['storage_path'] as String;
        try {
          final photoService = locator<PhotoService>();
          await Supabase.instance.client.storage
              .from(photoService.bucket)
              .remove([storagePath]);
        } catch (_) {}
        try {
          await Supabase.instance.client
              .from('user_photos')
              .delete()
              .eq('id', id);
        } catch (_) {}
      }
    } catch (_) {}
  }
}


