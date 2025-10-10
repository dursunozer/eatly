import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/meal_photo.dart';
import 'photo_service.dart';

/// Yerel olarak (yalnızca cihazda) öğün fotoğraflarını tutar.
/// Gün bazlı saklar; saat 00:00'ı geçen fotoğraflar yüklenmez.
class MealPhotoService {
  static const String _prefsKey = 'meal_photos';
  final SupabaseClient _client = Supabase.instance.client;
  final PhotoService _photoService = PhotoService();

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
  Future<String> addPhoto(Uint8List bytes, {String? id}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    List<MealPhoto> photos = [];
    if (raw != null && raw.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
      photos = jsonList
          .map((json) => MealPhoto.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    final String photoId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    String? imagePath;
    try {
      final dir = await getApplicationDocumentsDirectory();
      imagePath = '${dir.path}/meal_thumb_$photoId.jpg';
      final file = File(imagePath);
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {
      imagePath = null;
    }

    final MealPhoto newPhoto = MealPhoto(
      id: photoId,
      imageBytes: bytes,
      imagePath: imagePath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      detectedItems: const [],
      nutritionInfo: null,
      notes: null,
      userId: null,
      isAnalyzing: true,
      isWaitingNetwork: false,
    );
    photos.insert(0, newPhoto);
    await prefs.setString(_prefsKey, jsonEncode(photos.map((p) => p.toJson()).toList()));
    return photoId;
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
      print('🔄 updateDetectedItems çağrıldı - ID: $id, Öğe sayısı: ${detectedItems.length}');
      
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) {
        print('❌ SharedPreferences\'da veri bulunamadı');
        return;
      }

      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      MealPhoto? updatedPhoto;
      
      for (int i = 0; i < list.length; i++) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(list[i] as Map);
        if (m['id'] == id) {
          print('✅ Fotoğraf bulundu, güncelleniyor...');
          final MealPhoto current = MealPhoto.fromJson(m);
          updatedPhoto = MealPhoto(
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
          list[i] = updatedPhoto.toJson();
          break;
        }
      }
      
      if (updatedPhoto == null) {
        print('❌ Fotoğraf bulunamadı - ID: $id');
        return;
      }
      
      // Yerel veriyi güncelle
      await prefs.setString(_prefsKey, jsonEncode(list));
      print('✅ Yerel veri güncellendi');
      
      // Veritabanına da kaydet (besin verilerini)
      print('🔄 Veritabanı senkronizasyonu başlatılıyor...');
      await _syncNutritionToDatabase(updatedPhoto);
    } catch (e) {
      print('❌ updateDetectedItems hatası: $e');
    }
  }

  /// Besin verilerini veritabanına senkronize et
  Future<void> _syncNutritionToDatabase(MealPhoto photo) async {
    try {
      print('🔄 Besin verileri veritabanına senkronize ediliyor...');
      final String? uid = _client.auth.currentUser?.id;
      if (uid == null) {
        print('❌ Kullanıcı ID bulunamadı');
        return;
      }
      print('✅ Kullanıcı ID: $uid');

      // Besin verilerini hazırla
      Map<String, dynamic>? nutritionData;
      if (photo.detectedItems.isNotEmpty) {
        // Tüm detected items'ların besin değerlerini topla
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        double totalFiber = 0;
        Map<String, double> totalVitamins = {};
        Map<String, double> totalMinerals = {};

        for (final item in photo.detectedItems) {
          final nutrition = item['nutrition'] as Map<String, dynamic>?;
          if (nutrition != null) {
            totalCalories += (nutrition['calories'] as num?)?.toDouble() ?? 0;
            totalProtein += (nutrition['protein'] as num?)?.toDouble() ?? 0;
            totalCarbs += (nutrition['carbohydrate'] as num?)?.toDouble() ?? 
                         (nutrition['carbs'] as num?)?.toDouble() ?? 0;
            totalFat += (nutrition['fat'] as num?)?.toDouble() ?? 0;
            totalFiber += (nutrition['fiber'] as num?)?.toDouble() ?? 0;

            // Vitaminler
            final vitamins = nutrition['vitamins'] as Map<String, dynamic>?;
            if (vitamins != null) {
              vitamins.forEach((key, value) {
                final currentValue = totalVitamins[key] ?? 0;
                final newValue = (value as num?)?.toDouble() ?? 0;
                totalVitamins[key] = currentValue + newValue;
              });
            }

            // Mineraller
            final minerals = nutrition['minerals'] as Map<String, dynamic>?;
            if (minerals != null) {
              minerals.forEach((key, value) {
                final currentValue = totalMinerals[key] ?? 0;
                final newValue = (value as num?)?.toDouble() ?? 0;
                totalMinerals[key] = currentValue + newValue;
              });
            }
          }
        }

        nutritionData = {
          'calories': totalCalories,
          'protein': totalProtein,
          'carbohydrate': totalCarbs,
          'fat': totalFat,
          'fiber': totalFiber,
          'vitamins': totalVitamins,
          'minerals': totalMinerals,
          'detected_items': photo.detectedItems,
        };
      }

      // Veritabanında bu fotoğrafa ait kaydı bul ve güncelle
      print('🔍 Veritabanında fotoğraf aranıyor (local_id ile)...');
      final response = await _client
          .from('user_photos')
          .select('id')
          .eq('user_id', uid)
          .eq('local_id', photo.id)
          .limit(1);

      print('📊 Bulunan kayıt sayısı: ${response.length}');
      
      if (response.isNotEmpty) {
        final photoId = response.first['id'] as String;
        print('✅ Fotoğraf bulundu, ID: $photoId');
        print('💾 Besin verileri güncelleniyor...');
        
        await _client
            .from('user_photos')
            .update({
              'nutrition': nutritionData,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', photoId);
            
        print('✅ Besin verileri başarıyla güncellendi!');
      } else {
        print('❌ Veritabanında fotoğraf bulunamadı');
        print('🔍 Aranan local_id: ${photo.id}');
      }
    } catch (e) {
      print('❌ Besin verileri senkronizasyon hatası: $e');
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
    MealPhoto? deletedPhoto;
    
    list.removeWhere((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final match = m['id'] == id;
      if (match) {
        deletedPhoto = MealPhoto.fromJson(m);
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
    
    // Veritabanından da sil
    if (deletedPhoto != null) {
      await _deleteFromDatabase(deletedPhoto!);
    }
  }

  /// Veritabanından fotoğrafı sil
  Future<void> _deleteFromDatabase(MealPhoto photo) async {
    try {
      final String? uid = _client.auth.currentUser?.id;
      if (uid == null) return;

      // Veritabanında bu fotoğrafa ait kaydı bul ve sil
      final response = await _client
          .from('user_photos')
          .select('id')
          .eq('user_id', uid)
          .eq('taken_at', photo.createdAt.toUtc().toIso8601String())
          .limit(1);

      if (response.isNotEmpty) {
        final photoId = response.first['id'] as String;
        await _client
            .from('user_photos')
            .update({
              'deleted': true,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', photoId);
      }
    } catch (e) {
      print('Error deleting from database: $e');
    }
  }
}


