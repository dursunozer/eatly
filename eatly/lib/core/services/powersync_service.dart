import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';

class SupabaseTokenProvider {
  Future<String?> getAuthToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken;
  }
}

class AppPowerSync {
  AppPowerSync._();
  static final AppPowerSync instance = AppPowerSync._();

  late final PowerSyncDatabase db;

  Future<void> initialize() async {
    // İstemci şeması: server tarafında replikasyonu olan tablo(lar)
    const Schema appSchema = Schema([
      Table('user_photos', [
        Column.text('user_id'),
        Column.text('storage_path'),
        Column.text('taken_at'),
        Column.integer('deleted'),
        Column.text('created_at'),
        Column.text('updated_at'),
      ]),
    ]);

    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      final String dbPath = '${dir.path}/powersync.db';
      db = PowerSyncDatabase(schema: appSchema, path: dbPath);
      await db.initialize();
    } else {
      // Web: Şimdilik PowerSync devre dışı; DB oluşturma yok
      throw UnsupportedError('PowerSync is disabled on web in this build');
    }

    // Gerekli yerel tabloyu oluştur
    await db.execute(
      'create table if not exists local_photos ('
      'id text primary key, '
      'local_path text not null, '
      'taken_at text not null, '
      'is_synced integer not null default 0, '
      'remote_path text)',
    );

    // Analiz kuyruğu: çevrimdışıyken başarısız olan analizleri bekletir
    await db.execute(
      'create table if not exists local_analysis ('
      'temp_id text primary key, '
      'raw_path text not null, '
      'created_at text not null, '
      'attempts integer not null default 0)'
    );

    // Not: Bağlantı için doğru Connector sınıfını kullanın (SDK sürümüne göre değişebilir).
    // Örnek: await db.connect(connector: PowerSyncWebSocketClient(
    //   endpoint: Uri.parse('wss://66be7773dc29913faf840d21.powersync.journeyapps.com'),
    //   getAuthToken: () async => SupabaseTokenProvider().getAuthToken(),
    // ));
  }
  
  /// Clear all local photos from the database
  Future<void> clearLocalPhotos() async {
    try {
      await db.execute('delete from local_photos');
      if (kDebugMode) {
        debugPrint('✅ [PowerSync] Tüm yerel fotoğraflar temizlendi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PowerSync] Yerel fotoğraflar temizlenirken hata: $e');
      }
    }
  }
  
  /// Mark all local photos as synced to prevent upload attempts
  Future<void> markAllPhotosAsSynced() async {
    try {
      await db.execute('update local_photos set is_synced = 1');
      if (kDebugMode) {
        debugPrint('✅ [PowerSync] Tüm yerel fotoğraflar senkronize edildi olarak işaretlendi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PowerSync] Fotoğraflar senkronize edildi olarak işaretlenirken hata: $e');
      }
    }
  }
}