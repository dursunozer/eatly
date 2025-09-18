import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_photo.dart';

/// Yerel olarak (yalnızca cihazda) öğün fotoğraflarını tutar.
/// Gün bazlı saklar; saat 00:00'ı geçen fotoğraflar yüklenmez.
class MealPhotoService {
  static const String _prefsKey = 'meal_photos';

  Future<List<MealPhoto>> loadTodayPhotos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return <MealPhoto>[];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    final List<MealPhoto> all = list
        .map((e) => MealPhoto.fromJson(e as Map<String, dynamic>))
        .toList();

    // Yalnızca bugünün fotoğraflarını döndür, yeni-en-üstte olacak şekilde sırala
    final List<MealPhoto> todays = all
        .where((p) => p.createdAt.isAfter(startOfDay))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return todays;
  }

  /// Fotoğrafı hemen listeye ekler ve id'yi döndürür.
  /// isAnalyzing=true olarak kaydedilir; analiz bitince güncellenir.
  Future<String> addPhoto(Uint8List bytes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    final List<dynamic> list = raw == null || raw.isEmpty
        ? <dynamic>[]
        : (jsonDecode(raw) as List<dynamic>);

    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    String? imagePath;
    try {
      final dir = await getApplicationDocumentsDirectory();
      imagePath = '${dir.path}/meal_thumb_$id.jpg';
      final file = File(imagePath);
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {
      imagePath = null;
    }

    final MealPhoto photo = MealPhoto(
      id: id,
      imageBytes: null,
      imagePath: imagePath,
      createdAt: DateTime.now(),
      updatedAt: null,
      detectedItems: const [],
      nutritionInfo: null,
      notes: null,
      userId: null,
      isAnalyzing: true,
      isWaitingNetwork: false,
    );
    list.add(photo.toJson());

    await prefs.setString(_prefsKey, jsonEncode(list));
    return id;
  }

  Future<void> markWaitingNetwork({required String id, required bool waiting}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (int i = 0; i < list.length; i++) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(list[i] as Map);
        if (m['id'] == id) {
          final MealPhoto current = MealPhoto.fromJson(m);
          final MealPhoto next = current.copyWith(
            isWaitingNetwork: waiting,
            isAnalyzing: !waiting && current.isAnalyzing ? true : current.isAnalyzing,
          );
          list[i] = next.toJson();
          break;
        }
      }
      await prefs.setString(_prefsKey, jsonEncode(list));
    } catch (_) {}
  }

  Future<void> markAnalyzing({required String id, required bool analyzing}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (int i = 0; i < list.length; i++) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(list[i] as Map);
        if (m['id'] == id) {
          final MealPhoto current = MealPhoto.fromJson(m);
          final MealPhoto next = current.copyWith(
            isAnalyzing: analyzing,
          );
          list[i] = next.toJson();
          break;
        }
      }
      await prefs.setString(_prefsKey, jsonEncode(list));
    } catch (_) {}
  }

  /// Analiz tamamlandığında tespit edilen öğeler ve besin bilgisiyle kaydı günceller.
  Future<void> updateDetectedItems({
    required String id,
    required List<Map<String, dynamic>> detectedItems,
    Map<String, dynamic>? nutritionInfo,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;

      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (int i = 0; i < list.length; i++) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(list[i] as Map);
        if (m['id'] == id) {
          final MealPhoto current = MealPhoto.fromJson(m);
          final MealPhoto next = MealPhoto(
            id: current.id,
            imageBytes: current.imageBytes,
            imagePath: current.imagePath,
            createdAt: current.createdAt,
            updatedAt: DateTime.now(),
            detectedItems: detectedItems,
            nutritionInfo: nutritionInfo,
            notes: current.notes,
            userId: current.userId,
            isAnalyzing: false,
          );
          list[i] = next.toJson();
          break;
        }
      }
      await prefs.setString(_prefsKey, jsonEncode(list));
    } catch (_) {
      // Hata durumunda sessizce geç
    }
  }

  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  /// Yerel listeden ve varsa thumb dosyasından siler
  Future<void> deleteMealPhoto(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;

    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    list.removeWhere((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final match = m['id'] == id;
      if (match) {
        final path = m['image_path'] as String?;
        if (path != null && path.isNotEmpty) {
          try {
            final f = File(path);
            if (f.existsSync()) {
              f.deleteSync();
            }
          } catch (_) {}
        }
      }
      return match;
    });

    await prefs.setString(_prefsKey, jsonEncode(list));
  }
}


