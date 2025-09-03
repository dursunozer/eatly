class FoodItem {
  final String id;
  final String name;
  final String imagePath;
  final DateTime consumedAt;
  final double portion; // gram
  final NutritionInfo nutritionInfo;

  FoodItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.consumedAt,
    required this.portion,
    required this.nutritionInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'consumedAt': consumedAt.toIso8601String(),
      'portion': portion,
      'nutritionInfo': nutritionInfo.toJson(),
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
      consumedAt: DateTime.parse(json['consumedAt']),
      portion: json['portion'].toDouble(),
      nutritionInfo: NutritionInfo.fromJson(json['nutritionInfo']),
    );
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final Map<String, double> vitamins; // A, B1, B2, B6, B12, C, D, E, K
  final Map<String, double> minerals; // Kalsiyum, Demir, Magnezyum, Fosfor, Potasyum, Sodyum, Çinko

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.vitamins,
    required this.minerals,
  });

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'vitamins': vitamins,
      'minerals': minerals,
    };
  }

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
      vitamins: Map<String, double>.from(json['vitamins']),
      minerals: Map<String, double>.from(json['minerals']),
    );
  }
}

