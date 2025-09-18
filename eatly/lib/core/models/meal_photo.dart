import 'dart:convert';
import 'dart:typed_data';

/// Gün içinde çekilen öğün fotoğrafını temsil eder
class MealPhoto {
  final String id;
  final Uint8List? imageBytes;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Map<String, dynamic>> detectedItems;
  final Map<String, dynamic>? nutritionInfo;
  final String? notes;
  final String? userId;
  final bool isAnalyzing;
  final bool isWaitingNetwork;

  const MealPhoto({
    required this.id,
    this.imageBytes,
    this.imagePath,
    required this.createdAt,
    this.updatedAt,
    this.detectedItems = const [],
    this.nutritionInfo,
    this.notes,
    this.userId,
    this.isAnalyzing = false,
    this.isWaitingNetwork = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        if (imageBytes != null) 'b64': base64Encode(imageBytes!),
        'image_path': imagePath,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'detected_items': detectedItems,
        'nutrition_info': nutritionInfo,
        'notes': notes,
        'user_id': userId,
        'is_analyzing': isAnalyzing,
        'is_waiting_network': isWaitingNetwork,
      };

  factory MealPhoto.fromJson(Map<String, dynamic> json) {
    return MealPhoto(
      id: json['id'],
      imageBytes: json['b64'] != null ? base64Decode(json['b64']) : null,
      imagePath: json['image_path'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      detectedItems: List<Map<String, dynamic>>.from(json['detected_items'] ?? []),
      nutritionInfo: json['nutrition_info'],
      notes: json['notes'],
      userId: json['user_id'],
      isAnalyzing: (json['is_analyzing'] as bool?) ?? false,
      isWaitingNetwork: (json['is_waiting_network'] as bool?) ?? false,
    );
  }

  MealPhoto copyWith({
    String? id,
    Uint8List? imageBytes,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? detectedItems,
    Map<String, dynamic>? nutritionInfo,
    String? notes,
    String? userId,
    bool? isAnalyzing,
    bool? isWaitingNetwork,
  }) {
    return MealPhoto(
      id: id ?? this.id,
      imageBytes: imageBytes ?? this.imageBytes,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      detectedItems: detectedItems ?? this.detectedItems,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isWaitingNetwork: isWaitingNetwork ?? this.isWaitingNetwork,
    );
  }
}