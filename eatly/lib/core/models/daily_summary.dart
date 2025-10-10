import 'food_item.dart';

class DailySummary {
  final DateTime date;
  final List<FoodItem> foods;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  final double? _totalCalories;
  final double? _totalProtein;
  final double? _totalCarbs;
  final double? _totalFat;
  final double? _totalFiber;
  final double? _totalSaturatedFat;
  final double? _totalTransFat;
  final double? _totalPolyunsaturatedFat;
  final double? _totalMonounsaturatedFat;
  final double? _totalCholesterol;
  final double? _totalSodium;
  final double? _totalSugars;
  final double? _totalVitaminA;
  final double? _totalVitaminC;
  final double? _totalVitaminD;
  final double? _totalCalcium;
  final double? _totalIron;
  final double? _totalPotassium;
  final Map<String, double>? _totalVitamins;
  final Map<String, double>? _totalMinerals;

  DailySummary({
    required this.date,
    required this.foods,
    this.targetCalories = 2000,
    this.targetProtein = 50,
    this.targetCarbs = 275,
    this.targetFat = 65,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? totalFiber,
    double? totalSaturatedFat,
    double? totalTransFat,
    double? totalPolyunsaturatedFat,
    double? totalMonounsaturatedFat,
    double? totalCholesterol,
    double? totalSodium,
    double? totalSugars,
    double? totalVitaminA,
    double? totalVitaminC,
    double? totalVitaminD,
    double? totalCalcium,
    double? totalIron,
    double? totalPotassium,
    Map<String, double>? totalVitamins,
    Map<String, double>? totalMinerals,
  }) : _totalCalories = totalCalories,
       _totalProtein = totalProtein,
       _totalCarbs = totalCarbs,
       _totalFat = totalFat,
       _totalFiber = totalFiber,
       _totalSaturatedFat = totalSaturatedFat,
       _totalTransFat = totalTransFat,
       _totalPolyunsaturatedFat = totalPolyunsaturatedFat,
       _totalMonounsaturatedFat = totalMonounsaturatedFat,
       _totalCholesterol = totalCholesterol,
       _totalSodium = totalSodium,
       _totalSugars = totalSugars,
       _totalVitaminA = totalVitaminA,
       _totalVitaminC = totalVitaminC,
       _totalVitaminD = totalVitaminD,
       _totalCalcium = totalCalcium,
       _totalIron = totalIron,
       _totalPotassium = totalPotassium,
       _totalVitamins = totalVitamins,
       _totalMinerals = totalMinerals;

  double get totalCalories => _totalCalories ?? 
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.calories);

  double get totalProtein => _totalProtein ?? 
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.protein);

  double get totalCarbs => _totalCarbs ?? 
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.carbs);

  double get totalFat => _totalFat ?? 
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.fat);

  double get totalFiber => _totalFiber ?? 
      foods.fold(0, (sum, food) => sum + food.nutritionInfo.fiber);

  double get totalSaturatedFat => _totalSaturatedFat ?? 0;
  double get totalTransFat => _totalTransFat ?? 0;
  double get totalPolyunsaturatedFat => _totalPolyunsaturatedFat ?? 0;
  double get totalMonounsaturatedFat => _totalMonounsaturatedFat ?? 0;
  double get totalCholesterol => _totalCholesterol ?? 0;
  double get totalSodium => _totalSodium ?? 0;
  double get totalSugars => _totalSugars ?? 0;
  double get totalVitaminA => _totalVitaminA ?? 0;
  double get totalVitaminC => _totalVitaminC ?? 0;
  double get totalVitaminD => _totalVitaminD ?? 0;
  double get totalCalcium => _totalCalcium ?? 0;
  double get totalIron => _totalIron ?? 0;
  double get totalPotassium => _totalPotassium ?? 0;

  Map<String, double> get totalVitamins {
    if (_totalVitamins != null) return _totalVitamins!;
    
    final vitamins = <String, double>{};
    for (final food in foods) {
      food.nutritionInfo.vitamins.forEach((key, value) {
        vitamins[key] = (vitamins[key] ?? 0) + value;
      });
    }
    return vitamins;
  }

  Map<String, double> get totalMinerals {
    if (_totalMinerals != null) return _totalMinerals!;
    
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
