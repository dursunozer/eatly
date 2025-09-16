import '../models/meal_photo.dart';
import 'supabase_service.dart';

class MealService {
  final _supabaseService = SupabaseService();
  
  Future<List<MealPhoto>> getUserMealPhotos({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseService
          .from('meal_photos')
          .select('*')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List)
          .map((json) => MealPhoto.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching meal photos: $e');
      return [];
    }
  }
  
  Future<MealPhoto?> getMealPhotoById(String id) async {
    try {
      final response = await _supabaseService
          .from('meal_photos')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      
      if (response != null) {
        return MealPhoto.fromJson(response);
      }
    } catch (e) {
      print('Error fetching meal photo: $e');
    }
    
    return null;
  }
  
  Future<String> saveMealPhoto({
    required String imagePath,
    required List<Map<String, dynamic>> detectedItems,
    Map<String, dynamic>? nutritionInfo,
    String? notes,
  }) async {
    try {
      final response = await _supabaseService
          .from('meal_photos')
          .insert({
            'image_path': imagePath,
            'detected_items': detectedItems,
            'nutrition_info': nutritionInfo,
            'notes': notes,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();
      
      return response['id'];
    } catch (e) {
      print('Error saving meal photo: $e');
      rethrow;
    }
  }
  
  Future<void> updateMealPhoto(String id, {
    String? notes,
    Map<String, dynamic>? nutritionInfo,
  }) async {
    try {
      await _supabaseService
          .from('meal_photos')
          .update({
            if (notes != null) 'notes': notes,
            if (nutritionInfo != null) 'nutrition_info': nutritionInfo,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      print('Error updating meal photo: $e');
      rethrow;
    }
  }
  
  Future<void> deleteMealPhoto(String id) async {
    try {
      await _supabaseService
          .from('meal_photos')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting meal photo: $e');
      rethrow;
    }
  }
  
  Future<List<MealPhoto>> getMealPhotosByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabaseService
          .from('meal_photos')
          .select('*')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => MealPhoto.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching meal photos by date range: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> getMealStatistics() async {
    try {
      // Son 7 günün istatistiklerini getir
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final photos = await getMealPhotosByDateRange(
        startDate: weekAgo,
        endDate: DateTime.now(),
      );
      
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      
      for (final photo in photos) {
        if (photo.nutritionInfo != null) {
          final nutrition = photo.nutritionInfo!;
          totalCalories += (nutrition['calories'] as num?)?.toDouble() ?? 0;
          totalProtein += (nutrition['protein'] as num?)?.toDouble() ?? 0;
          totalCarbs += (nutrition['carbs'] as num?)?.toDouble() ?? 0;
          totalFat += (nutrition['fat'] as num?)?.toDouble() ?? 0;
        }
      }
      
      return {
        'totalPhotos': photos.length,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'averageCaloriesPerDay': photos.isNotEmpty ? totalCalories / 7 : 0,
        'period': '7 days',
      };
    } catch (e) {
      print('Error getting meal statistics: $e');
      return {};
    }
  }
}
