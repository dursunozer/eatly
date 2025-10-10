import 'package:stacked/stacked.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/meal_photo.dart';
import '../../../core/models/daily_summary.dart';
import '../../../core/services/meal_photo_service.dart';
import '../../../core/services/history_service.dart';

class MealHistoryViewModel extends BaseViewModel {
  final MealPhotoService _mealPhotoService = MealPhotoService();
  final HistoryService _historyService = HistoryService();
  final SupabaseClient _client = Supabase.instance.client;
  
  List<MealPhoto> _meals = [];
  DailySummary? _dailySummary;
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1)); // Varsayılan: dün
  DateTime _focusedDay = DateTime.now().subtract(const Duration(days: 1));
  bool _isLoading = false;
  
  List<MealPhoto> get meals => _meals;
  DailySummary? get dailySummary => _dailySummary;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDay => _focusedDay;
  bool get isLoading => _isLoading;
  
  Future<void> loadMeals() async {
    await loadDataForDate(_selectedDate);
  }
  
  Future<void> loadDataForDate(DateTime date) async {
    _isLoading = true;
    _selectedDate = date;
    notifyListeners();
    
    try {
      // Meals ve summary'yi paralel yükle
      final results = await Future.wait([
        _historyService.getMealPhotosForDate(date),
        _historyService.getDailySummaryForDate(date),
      ]);
      
      _meals = results[0] as List<MealPhoto>;
      _dailySummary = results[1] as DailySummary;
    } catch (e) {
      print('Error loading data for date: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDate = selectedDay;
    _focusedDay = focusedDay;
    loadDataForDate(selectedDay);
  }
  
  Future<void> updatePortionSize(String mealId, String itemName, double portionSize) async {
    try {
      // Find the meal
      final index = _meals.indexWhere((meal) => meal.id == mealId);
      if (index != -1) {
        // Update portion sizes
        final meal = _meals[index];
        final updatedPortionSizes = Map<String, double>.from(meal.portionSizes ?? {});
        updatedPortionSizes[itemName] = portionSize;
        
        // Create updated meal
        final updatedMeal = meal.copyWith(portionSizes: updatedPortionSizes);
        _meals[index] = updatedMeal;
        
        // Update in storage
        // This would require updating the MealPhotoService to support portion size updates
        notifyListeners();
      }
    } catch (e) {
      print('Error updating portion size: $e');
    }
  }
}