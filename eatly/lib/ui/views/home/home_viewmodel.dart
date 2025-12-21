import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../../core/models/daily_summary.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/photo_service.dart';
import '../../../core/services/powersync_service.dart';
import '../../../core/services/meal_photo_service.dart';
import '../../../core/models/meal_photo.dart';
import '../../../app/app.locator.dart';
import '../../../core/services/app_events.dart';

class HomeViewModel extends BaseViewModel with WidgetsBindingObserver {
  final _authService = locator<AuthService>();
  final _photoService = locator<PhotoService>();
  final MealPhotoService _mealPhotoService = MealPhotoService();
  
  String? displayName;
  Future<List<MealPhoto>>? _todayMealPhotosFuture;
  
  // Kullanıcı profili cache
  UserProfile? _userProfile;
  
  // Günlük özet hesaplaması için metod
  DailySummary calculateDailySummary(List<MealPhoto> photos) {
    final today = DateTime.now();
    
    // Kullanıcı profilinden hedef değerleri al (varsayılan değerler ile)
    final targetCalories = _userProfile?.effectiveTargetCalories ?? 2000.0;
    final targetProtein = _userProfile?.effectiveTargetProtein ?? 150.0;
    final targetCarbs = _userProfile?.effectiveTargetCarbs ?? 250.0;
    final targetFat = _userProfile?.effectiveTargetFat ?? 65.0;
    
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    // Her meal photo'daki detected items'ları topla
    for (final photo in photos) {
      for (final item in photo.detectedItems) {
        final nutrition = item['nutrition'] as Map<String, dynamic>?;
        if (nutrition != null) {
          totalCalories += (nutrition['calories'] as num?)?.toDouble() ?? 0;
          totalProtein += (nutrition['protein'] as num?)?.toDouble() ?? 0;
          totalCarbs += (nutrition['carbohydrate'] as num?)?.toDouble() ?? 
                       (nutrition['carbs'] as num?)?.toDouble() ?? 0;
          totalFat += (nutrition['fat'] as num?)?.toDouble() ?? 0;
        }
      }
    }
    
    return DailySummary(
      date: today,
      foods: [], // Artık kullanmıyoruz, sadece hesaplama için
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
    );
  }

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
    WidgetsBinding.instance.addObserver(this);
    // App içi olaylar: foto eklendi / analiz tamamlandı -> yenile
    AppEvents.instance.stream.listen((event) {
      switch (event.type) {
        case AppEventType.photoAdded:
        case AppEventType.photoAnalyzed:
          refreshPhotos();
          break;
      }
    });
    try {
      final uid = _authService.currentUserId;
      if (uid != null) {
        final profile = await ProfileService.fetchProfile(uid);
        final name = (profile?['display_name'] as String?)?.trim();
        displayName = (name != null && name.isNotEmpty) ? name : null;
        
        // Kullanıcı profili hedef değerleri için
        if (profile != null) {
          _userProfile = UserProfile.fromJson(profile);
        }
      }
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshPhotos();
    }
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
    // Cache'i temizle ve UI'yi yenile - bu günlük özet değerlerini de güncelleyecek
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
