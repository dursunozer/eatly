class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? birthDate;
  final String? gender;
  final double? height;
  final double? weight;
  final String? activityLevel;
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
    this.gender,
    this.height,
    this.weight,
    this.activityLevel,
    this.dietaryPreferences,
    this.timezone,
    this.createdAt,
    this.updatedAt,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      gender: json['gender'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      activityLevel: json['activity_level'],
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
      'gender': gender,
      'height': height,
      'weight': weight,
      'activity_level': activityLevel,
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
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
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
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
