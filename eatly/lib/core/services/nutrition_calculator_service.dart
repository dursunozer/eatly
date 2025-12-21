/// Beslenme hedeflerini hesaplayan servis
/// BMR (Bazal Metabolizma Hızı), TDEE (Günlük Toplam Enerji Harcaması) ve
/// makro besin değerlerini hesaplar.
class NutritionCalculatorService {
  NutritionCalculatorService._();

  // Hedef türleri
  static const String goalLoseWeight = 'lose_weight';
  static const String goalGainWeight = 'gain_weight';
  static const String goalMaintain = 'maintain';
  static const String goalBuildMuscle = 'build_muscle';

  // Aktivite seviyeleri
  static const String activitySedentary = 'sedentary';
  static const String activityLightlyActive = 'lightly_active';
  static const String activityModeratelyActive = 'moderately_active';
  static const String activityActive = 'active';
  static const String activityVeryActive = 'very_active';

  // Aktivite çarpanları
  static const Map<String, double> activityMultipliers = {
    activitySedentary: 1.2,
    activityLightlyActive: 1.375,
    activityModeratelyActive: 1.55,
    activityActive: 1.725,
    activityVeryActive: 1.9,
  };

  // Hedef bazlı kalori ayarlamaları
  static const Map<String, int> goalCalorieAdjustments = {
    goalLoseWeight: -500,
    goalGainWeight: 500,
    goalMaintain: 0,
    goalBuildMuscle: 300,
  };

  /// BMR hesaplama (Mifflin-St Jeor formülü)
  /// [weight] kg cinsinden
  /// [height] cm cinsinden
  /// [age] yıl cinsinden
  /// [isMale] erkek ise true, kadın ise false
  static double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required bool isMale,
  }) {
    // Mifflin-St Jeor formülü
    // Erkek: BMR = 10 × kilo + 6.25 × boy − 5 × yaş + 5
    // Kadın: BMR = 10 × kilo + 6.25 × boy − 5 × yaş − 161
    final baseBMR = (10 * weight) + (6.25 * height) - (5 * age);
    return isMale ? baseBMR + 5 : baseBMR - 161;
  }

  /// TDEE hesaplama (Günlük Toplam Enerji Harcaması)
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    final multiplier = activityMultipliers[activityLevel] ?? 1.2;
    return bmr * multiplier;
  }

  /// Hedef kalori hesaplama
  static double calculateTargetCalories({
    required double tdee,
    required String goal,
  }) {
    final adjustment = goalCalorieAdjustments[goal] ?? 0;
    final targetCalories = tdee + adjustment;
    // Minimum 1200 kalori güvenlik sınırı
    return targetCalories < 1200 ? 1200 : targetCalories;
  }

  /// Protein hedefi hesaplama (gram)
  /// Kilo verme ve kas kütlesi için 2g/kg, diğerleri için 1.6g/kg
  static double calculateTargetProtein({
    required double weight,
    required String goal,
  }) {
    final proteinPerKg = (goal == goalLoseWeight || goal == goalBuildMuscle) 
        ? 2.0 
        : 1.6;
    return weight * proteinPerKg;
  }

  /// Yağ hedefi hesaplama (gram)
  /// Toplam kalorinin %25'i
  static double calculateTargetFat({
    required double targetCalories,
  }) {
    // 1 gram yağ = 9 kalori
    return (targetCalories * 0.25) / 9;
  }

  /// Karbonhidrat hedefi hesaplama (gram)
  /// Kalan kalori (protein ve yağ çıkarıldıktan sonra)
  static double calculateTargetCarbs({
    required double targetCalories,
    required double targetProtein,
    required double targetFat,
  }) {
    // 1 gram protein = 4 kalori
    // 1 gram karbonhidrat = 4 kalori
    // 1 gram yağ = 9 kalori
    final proteinCalories = targetProtein * 4;
    final fatCalories = targetFat * 9;
    final remainingCalories = targetCalories - proteinCalories - fatCalories;
    return remainingCalories / 4;
  }

  /// Tüm hedefleri tek seferde hesapla
  static NutritionTargets calculateAllTargets({
    required double weight,
    required double height,
    required int age,
    required bool isMale,
    required String activityLevel,
    required String goal,
  }) {
    final bmr = calculateBMR(
      weight: weight,
      height: height,
      age: age,
      isMale: isMale,
    );

    final tdee = calculateTDEE(
      bmr: bmr,
      activityLevel: activityLevel,
    );

    final targetCalories = calculateTargetCalories(
      tdee: tdee,
      goal: goal,
    );

    final targetProtein = calculateTargetProtein(
      weight: weight,
      goal: goal,
    );

    final targetFat = calculateTargetFat(
      targetCalories: targetCalories,
    );

    final targetCarbs = calculateTargetCarbs(
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetFat: targetFat,
    );

    return NutritionTargets(
      bmr: bmr,
      tdee: tdee,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
    );
  }

  /// Hedef için Türkçe açıklama
  static String getGoalDisplayName(String goal) {
    switch (goal) {
      case goalLoseWeight:
        return 'Kilo Vermek';
      case goalGainWeight:
        return 'Kilo Almak';
      case goalMaintain:
        return 'Kilomu Korumak';
      case goalBuildMuscle:
        return 'Kas Kütlesi Kazanmak';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Aktivite seviyesi için Türkçe açıklama
  static String getActivityDisplayName(String activityLevel) {
    switch (activityLevel) {
      case activitySedentary:
        return 'Hareketsiz';
      case activityLightlyActive:
        return 'Hafif Aktif';
      case activityModeratelyActive:
        return 'Orta Aktif';
      case activityActive:
        return 'Aktif';
      case activityVeryActive:
        return 'Çok Aktif';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Aktivite seviyesi için açıklama
  static String getActivityDescription(String activityLevel) {
    switch (activityLevel) {
      case activitySedentary:
        return 'Masa başı iş, çok az veya hiç egzersiz yok';
      case activityLightlyActive:
        return 'Hafif egzersiz veya spor (haftada 1-3 gün)';
      case activityModeratelyActive:
        return 'Orta düzey egzersiz veya spor (haftada 3-5 gün)';
      case activityActive:
        return 'Yoğun egzersiz veya spor (haftada 6-7 gün)';
      case activityVeryActive:
        return 'Çok yoğun egzersiz veya fiziksel iş';
      default:
        return '';
    }
  }
}

/// Hesaplanan beslenme hedefleri
class NutritionTargets {
  final double bmr;
  final double tdee;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  const NutritionTargets({
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });

  @override
  String toString() {
    return 'NutritionTargets(bmr: ${bmr.toStringAsFixed(0)}, tdee: ${tdee.toStringAsFixed(0)}, '
        'calories: ${targetCalories.toStringAsFixed(0)}, protein: ${targetProtein.toStringAsFixed(0)}g, '
        'carbs: ${targetCarbs.toStringAsFixed(0)}g, fat: ${targetFat.toStringAsFixed(0)}g)';
  }
}


