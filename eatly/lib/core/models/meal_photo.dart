import 'dart:convert';
import 'dart:typed_data';

/// Gün içinde çekilen öğün fotoğrafını temsil eder
class MealPhoto {
  final Uint8List imageBytes;
  final DateTime timestamp;

  MealPhoto({required this.imageBytes, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'b64': base64Encode(imageBytes),
        'ts': timestamp.millisecondsSinceEpoch,
      };

  static MealPhoto fromJson(Map<String, dynamic> json) {
    final String b64 = json['b64'] as String;
    final int ts = json['ts'] as int;
    return MealPhoto(
      imageBytes: base64Decode(b64),
      timestamp: DateTime.fromMillisecondsSinceEpoch(ts),
    );
  }
}


