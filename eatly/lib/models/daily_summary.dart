import 'food_item.dart';

class DailySummary {
  final DateTime date;
  final List<FoodItem> foods;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  DailySummary({
    required this.date,
    required this.foods,
    this.targetCalories = 2000,
    this.targetProtein = 50,
    this.targetCarbs = 275,
    this.targetFat = 65,
  });

  double get totalCalories =>
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.calories);

  double get totalProtein =>
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.protein);

  double get totalCarbs =>
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.carbs);

  double get totalFat =>
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.fat);

  double get totalFiber =>
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.fiber);

  Map<String, double> get totalVitamins {
    final vitamins = <String, double>{};
    for (final food in foods) {
      food.nutritionInfo.vitamins.forEach((key, value) {
        vitamins[key] = (vitamins[key] ?? 0) + value;
      });
    }
    return vitamins;
  }

  Map<String, double> get totalMinerals {
    final minerals = <String, double>{};
    for (final food in foods) {
      food.nutritionInfo.minerals.forEach((key, value) {
        minerals[key] = (minerals[key] ?? 0) + value;
      });
    }
    return minerals;
  }

  double get caloriesProgress => totalCalories / targetCalories;
  double get proteinProgress => totalProtein / targetProtein;
  double get carbsProgress => totalCarbs / targetCarbs;
  double get fatProgress => totalFat / targetFat;
}

