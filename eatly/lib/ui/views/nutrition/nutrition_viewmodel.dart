import 'package:stacked/stacked.dart';
import '../../../models/daily_summary.dart';
import '../../../models/food_item.dart';

class NutritionViewModel extends BaseViewModel {
  final DailySummary dailySummary = DailySummary(
    date: DateTime.now(),
    foods: [
      FoodItem(
        id: '1',
        name: 'Kahvaltı - Yumurta',
        imagePath: '',
        consumedAt: DateTime.now().subtract(const Duration(hours: 4)),
        portion: 100,
        nutritionInfo: NutritionInfo(
          calories: 155,
          protein: 13,
          carbs: 1.1,
          fat: 11,
          fiber: 0,
          vitamins: {'A': 540, 'D': 2, 'B12': 0.9},
          minerals: {'Demir': 1.8, 'Kalsiyum': 56},
        ),
      ),
    ],
  );
}


