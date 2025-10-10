import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_summary.dart';
import '../models/meal_photo.dart';
import 'meal_photo_service.dart';

class HistoryService {
  final SupabaseClient _client = Supabase.instance.client;
  final MealPhotoService _mealPhotoService = MealPhotoService();

  /// Belirli bir tarihteki meal photo'ları getir
  Future<List<MealPhoto>> getMealPhotosForDate(DateTime date) async {
    final String? uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    final List<MealPhoto> allPhotos = [];

    // 1. Veritabanından veri çek
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('user_photos')
          .select('*')
          .eq('user_id', uid)
          .eq('deleted', false)
          .gte('taken_at', startOfDay.toIso8601String())
          .lt('taken_at', endOfDay.toIso8601String())
          .order('taken_at', ascending: false);

      final dbPhotos = (response as List)
          .map((json) => _mapToMealPhoto(json))
          .toList();
      
      allPhotos.addAll(dbPhotos);
    } catch (e) {
      print('Error fetching meal photos from database: $e');
    }

    // 2. Eğer bugün ise, yerel SharedPreferences'tan da veri çek
    final today = DateTime.now();
    final isToday = date.year == today.year && 
                   date.month == today.month && 
                   date.day == today.day;
    
    if (isToday) {
      try {
        final localPhotos = await _mealPhotoService.loadTodayPhotos();
        
        // Veritabanında olmayan yerel fotoğrafları ekle
        for (final localPhoto in localPhotos) {
          final existsInDb = allPhotos.any((dbPhoto) => dbPhoto.id == localPhoto.id);
          if (!existsInDb) {
            allPhotos.add(localPhoto);
          }
        }
      } catch (e) {
        print('Error fetching local meal photos: $e');
      }
    }

    // Tarihe göre sırala (en yeni üstte)
    allPhotos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return allPhotos;
  }

  /// Belirli bir tarih için günlük özet hesapla
  Future<DailySummary> getDailySummaryForDate(DateTime date) async {
    final photos = await getMealPhotosForDate(date);
    
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSaturatedFat = 0;
    double totalTransFat = 0;
    double totalPolyunsaturatedFat = 0;
    double totalMonounsaturatedFat = 0;
    double totalCholesterol = 0;
    double totalSodium = 0;
    double totalSugars = 0;
    double totalVitaminA = 0;
    double totalVitaminC = 0;
    double totalVitaminD = 0;
    double totalCalcium = 0;
    double totalIron = 0;
    double totalPotassium = 0;
    
    Map<String, double> totalVitamins = {};
    Map<String, double> totalMinerals = {};

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
          totalFiber += (nutrition['fiber'] as num?)?.toDouble() ?? 0;
          
          // Detaylı yağ bilgileri
          totalSaturatedFat += (nutrition['saturated_fat'] as num?)?.toDouble() ?? 0;
          totalTransFat += (nutrition['trans_fat'] as num?)?.toDouble() ?? 0;
          totalPolyunsaturatedFat += (nutrition['polyunsaturated_fat'] as num?)?.toDouble() ?? 0;
          totalMonounsaturatedFat += (nutrition['monounsaturated_fat'] as num?)?.toDouble() ?? 0;
          
          // Diğer önemli besinler
          totalCholesterol += (nutrition['cholesterol'] as num?)?.toDouble() ?? 0;
          totalSodium += (nutrition['sodium'] as num?)?.toDouble() ?? 0;
          totalSugars += (nutrition['sugars'] as num?)?.toDouble() ?? 0;
          
          // Vitaminler
          totalVitaminA += (nutrition['vitamin_a'] as num?)?.toDouble() ?? 0;
          totalVitaminC += (nutrition['vitamin_c'] as num?)?.toDouble() ?? 0;
          totalVitaminD += (nutrition['vitamin_d'] as num?)?.toDouble() ?? 0;
          
          // Mineraller
          totalCalcium += (nutrition['calcium'] as num?)?.toDouble() ?? 0;
          totalIron += (nutrition['iron'] as num?)?.toDouble() ?? 0;
          totalPotassium += (nutrition['potassium'] as num?)?.toDouble() ?? 0;

          // Eski vitamin/mineral formatı (eğer varsa)
          final vitamins = nutrition['vitamins'] as Map<String, dynamic>?;
          if (vitamins != null) {
            vitamins.forEach((key, value) {
              final currentValue = totalVitamins[key] ?? 0;
              final newValue = (value as num?)?.toDouble() ?? 0;
              totalVitamins[key] = currentValue + newValue;
            });
          }

          final minerals = nutrition['minerals'] as Map<String, dynamic>?;
          if (minerals != null) {
            minerals.forEach((key, value) {
              final currentValue = totalMinerals[key] ?? 0;
              final newValue = (value as num?)?.toDouble() ?? 0;
              totalMinerals[key] = currentValue + newValue;
            });
          }
        }
      }
    }

    return DailySummary(
      date: date,
      foods: [], // Artık kullanmıyoruz
      targetCalories: 2000,
      targetProtein: 150,
      targetCarbs: 250,
      targetFat: 65,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalFiber: totalFiber,
      totalSaturatedFat: totalSaturatedFat,
      totalTransFat: totalTransFat,
      totalPolyunsaturatedFat: totalPolyunsaturatedFat,
      totalMonounsaturatedFat: totalMonounsaturatedFat,
      totalCholesterol: totalCholesterol,
      totalSodium: totalSodium,
      totalSugars: totalSugars,
      totalVitaminA: totalVitaminA,
      totalVitaminC: totalVitaminC,
      totalVitaminD: totalVitaminD,
      totalCalcium: totalCalcium,
      totalIron: totalIron,
      totalPotassium: totalPotassium,
      totalVitamins: totalVitamins,
      totalMinerals: totalMinerals,
    );
  }

  /// Son N günün özetlerini getir
  Future<List<DailySummary>> getLastNDaysSummary(int days) async {
    final List<DailySummary> summaries = [];
    final today = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final summary = await getDailySummaryForDate(date);
      summaries.add(summary);
    }
    
    return summaries;
  }

  /// user_photos JSON'unu MealPhoto modeline dönüştür
  MealPhoto _mapToMealPhoto(Map<String, dynamic> json) {
    // user_photos tablosundaki nutrition verisini detectedItems formatına dönüştür
    final nutrition = json['nutrition'] as Map<String, dynamic>?;
    List<Map<String, dynamic>> detectedItems = [];
    
    if (nutrition != null) {
      // Eğer nutrition verisi varsa, bunu detectedItems formatına dönüştür
      detectedItems.add({
        'name': 'Öğün',
        'confidence': 1.0,
        'nutrition': nutrition,
      });
    }

    return MealPhoto(
      id: json['id'] ?? '',
      imageBytes: null,
      imagePath: json['storage_path'],
      createdAt: DateTime.parse(json['taken_at'] ?? json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      detectedItems: detectedItems,
      nutritionInfo: null,
      notes: null,
      userId: json['user_id'],
      isAnalyzing: false,
      isWaitingNetwork: false,
    );
  }
}
