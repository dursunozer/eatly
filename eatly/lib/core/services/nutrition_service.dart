import '../models/food_item.dart';
import '../models/daily_summary.dart';

class NutritionService {
  
  Future<List<FoodItem>> getTodaysFoods() async {
    // Bugünün yemek kayıtlarını getir
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    // Burada database'den veri çekme işlemi yapılacak
    // Şimdilik örnek veri dönüyoruz
    return [
      FoodItem(
        id: '1',
        name: 'Yumurta',
        imagePath: '',
        consumedAt: DateTime.now(),
        portion: 100,
        nutritionInfo: NutritionInfo(
          calories: 150,
          protein: 12,
          carbs: 1,
          fat: 10,
          fiber: 0,
          vitamins: {},
          minerals: {},
        ),
      ),
      FoodItem(
        id: '2',
        name: 'Ekmek',
        imagePath: '',
        consumedAt: DateTime.now(),
        portion: 50,
        nutritionInfo: NutritionInfo(
          calories: 200,
          protein: 6,
          carbs: 40,
          fat: 2,
          fiber: 2,
          vitamins: {},
          minerals: {},
        ),
      ),
    ];
  }
  
  Future<DailySummary> getDailySummary() async {
    final foods = await getTodaysFoods();
    
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    for (final food in foods) {
      totalCalories += food.nutritionInfo.calories;
      totalProtein += food.nutritionInfo.protein;
      totalCarbs += food.nutritionInfo.carbs;
      totalFat += food.nutritionInfo.fat;
    }
    
    return DailySummary(
      date: DateTime.now(),
      foods: foods,
      targetCalories: 2000, // Kullanıcının hedefi
      targetProtein: 150,
      targetCarbs: 250,
      targetFat: 65,
    );
  }
  
  Future<void> addFoodItem(FoodItem foodItem) async {
    // Database'e yemek ekle
    // Şimdilik sadece log
    print('Adding food item: ${foodItem.name}');
  }
  
  Future<void> deleteFoodItem(String foodId) async {
    // Database'den yemek sil
    print('Deleting food item: $foodId');
  }
  
  Future<void> updateFoodItem(FoodItem foodItem) async {
    // Database'de yemek güncelle
    print('Updating food item: ${foodItem.name}');
  }
  
  // Beslenme önerileri
  List<String> getNutritionTips() {
    return [
      'Günde en az 2 litre su için',
      'Her öğünde protein tüketin',
      'Renkli sebze ve meyveler tercih edin',
      'İşlenmiş gıdalardan kaçının',
      'Porsiyon kontrolü yapın',
    ];
  }
  
  // Kalori hesaplamaları
  double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required String gender,
  }) {
    // Harris-Benedict formülü
    if (gender.toLowerCase() == 'erkek') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }
  
  double calculateTDEE(double bmr, String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return bmr * 1.2;
      case 'lightly_active':
        return bmr * 1.375;
      case 'moderately_active':
        return bmr * 1.55;
      case 'very_active':
        return bmr * 1.725;
      case 'extremely_active':
        return bmr * 1.9;
      default:
        return bmr * 1.375; // Varsayılan: hafif aktif
    }
  }
}
