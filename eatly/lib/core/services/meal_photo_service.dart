import 'dart:convert';
import 'dart:typed_data';

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

  Future<void> addPhoto(Uint8List bytes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    final List<dynamic> list = raw == null || raw.isEmpty
        ? <dynamic>[]
        : (jsonDecode(raw) as List<dynamic>);

    final MealPhoto photo = MealPhoto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageBytes: bytes,
      createdAt: DateTime.now(),
    );
    list.add(photo.toJson());

    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}


