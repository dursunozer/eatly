import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../core/models/daily_summary.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/photo_service.dart';
import '../../../core/services/powersync_service.dart';
import '../../../core/services/meal_photo_service.dart';
import '../../../core/models/meal_photo.dart';
import '../../../app/app.locator.dart';

class HomeViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _photoService = locator<PhotoService>();
  final MealPhotoService _mealPhotoService = MealPhotoService();
  final DailySummary todaySummary = DailySummary(
    date: DateTime.now(),
    foods: [],
  );

  String? displayName;
  Future<List<MealPhoto>>? _todayMealPhotosFuture;

  Future<List<MealPhoto>> get todayMealPhotosFuture {
    _todayMealPhotosFuture ??= loadTodayMealPhotos();
    return _todayMealPhotosFuture!;
  }

  String get formattedDate =>
      DateFormat('dd MMMM yyyy', 'tr_TR').format(DateTime.now());

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın! ☀️';
    if (hour < 17) return 'İyi Öğlenler! 🌤️';
    return 'İyi Akşamlar! 🌙';
  }

  Future<void> init() async {
    try {
      final uid = _authService.currentUserId;
      if (uid != null) {
        final profile = await ProfileService.fetchProfile(uid);
        final name = (profile?['display_name'] as String?)?.trim();
        displayName = (name != null && name.isNotEmpty) ? name : null;
      }
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }
  
  // Manuel yenileme - Future cache'ini temizler
  void refreshPhotos() {
    _todayMealPhotosFuture = null;
    notifyListeners();
  }
  
  // Öğün fotoğrafını sil (yerel + uzak)
  Future<void> deleteMealPhoto(String id) async {
    try {
      await _mealPhotoService.deleteMealPhoto(id);
      // Uzakta bugünkü en yeni kaydı deleted=true yap (yaklaşık eşleşme)
      await _photoService.markTodayPhotoDeletedApprox();
    } catch (_) {}
    // Cache'i temizle ve UI'yi yenile
    _todayMealPhotosFuture = null;
    notifyListeners();
  }
  
  Future<List<String>> getTodayPhotoUrls() async {
    try {
      return await _photoService.fetchTodayPhotoUrls();
    } catch (_) {
      return [];
    }
  }
  
  Future<List<String>> loadCombinedPhotos() async {
    // 1) Offline kuyruktan bugünkü senkronlanmamış dosyaları al (en yeni üste)
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    List<Map<String, Object?>> local = <Map<String, Object?>>[];
    try {
      final rows = await AppPowerSync.instance.db.getAll(
        'select local_path, taken_at from local_photos where is_synced = 0 and taken_at >= ? order by taken_at desc',
        [start.toIso8601String()],
      );
      local = rows
          .map(
            (r) => {
              'local_path': r['local_path'] as String,
              'taken_at': r['taken_at'] as String,
            },
          )
          .toList();
    } catch (_) {
      // Web veya DB hazır değilse local list boş kalsın
    }

    // 2) Supabase'ten bugünkü senkronlanmış URL'ler
    final remote = await getTodayPhotoUrls();

    // 3) Birleştir: önce local (file://), sonra remote
    final combined = <String>[
      ...local.map((e) => 'file://${e['local_path']}'),
      ...remote,
    ];
    return combined;
  }

  // Yeni: Bugünkü yerel öğün fotoğraflarını, analiz durumlarıyla getir
  Future<List<MealPhoto>> loadTodayMealPhotos() async {
    try {
      return await _mealPhotoService.loadTodayPhotos();
    } catch (e) {
      return <MealPhoto>[];
    }
  }
}
