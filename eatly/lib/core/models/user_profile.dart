class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? birthDate;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? activityLevel;
  final String? goal;
  final double? targetCalories;
  final double? targetProtein;
  final double? targetCarbs;
  final double? targetFat;
  final bool onboardingCompleted;
  final String? dietaryPreferences;
  final String? timezone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.birthDate,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.activityLevel,
    this.goal,
    this.targetCalories,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
    this.onboardingCompleted = false,
    this.dietaryPreferences,
    this.timezone,
    this.createdAt,
    this.updatedAt,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'] ?? json['display_name'],
      avatarUrl: json['avatar_url'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      age: json['age'] as int?,
      gender: json['gender'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      activityLevel: json['activity_level'],
      goal: json['goal'],
      targetCalories: json['target_calories']?.toDouble(),
      targetProtein: json['target_protein']?.toDouble(),
      targetCarbs: json['target_carbs']?.toDouble(),
      targetFat: json['target_fat']?.toDouble(),
      onboardingCompleted: json['onboarding_completed'] ?? false,
      dietaryPreferences: json['dietary_preferences'],
      timezone: json['timezone'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'birth_date': birthDate?.toIso8601String(),
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activity_level': activityLevel,
      'goal': goal,
      'target_calories': targetCalories,
      'target_protein': targetProtein,
      'target_carbs': targetCarbs,
      'target_fat': targetFat,
      'onboarding_completed': onboardingCompleted,
      'dietary_preferences': dietaryPreferences,
      'timezone': timezone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? birthDate,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
    String? goal,
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    bool? onboardingCompleted,
    String? dietaryPreferences,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Onboarding tamamlandı mı ve gerekli veriler var mı kontrol et
  bool get hasCompletedOnboarding => 
      onboardingCompleted && 
      targetCalories != null && 
      targetProtein != null;

  /// Varsayılan hedef değerlerini döndür (onboarding tamamlanmamışsa)
  double get effectiveTargetCalories => targetCalories ?? 2000;
  double get effectiveTargetProtein => targetProtein ?? 150;
  double get effectiveTargetCarbs => targetCarbs ?? 250;
  double get effectiveTargetFat => targetFat ?? 65;
}
