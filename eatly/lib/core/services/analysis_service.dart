import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'fatsecret_service.dart';
import 'meal_photo_service.dart';
import 'powersync_service.dart';
import 'app_events.dart';

class AnalysisService {
  AnalysisService._();
  static final AnalysisService instance = AnalysisService._();

  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      syncOnce();
    });
    // İlk tetikleme
    syncOnce();
  }

  Future<void> syncOnce() async {
    try {
      final db = AppPowerSync.instance.db;
      final rows = await db.getAll('select temp_id, raw_path, attempts from local_analysis order by created_at asc');
      for (final r in rows) {
        final String tempId = r['temp_id'] as String;
        final String rawPath = r['raw_path'] as String;
        try {
          // UI: ağ bekleniyor -> analiz başlıyor geçişi
          await MealPhotoService().markWaitingNetwork(id: tempId, waiting: false);
          await MealPhotoService().markAnalyzing(id: tempId, analyzing: true);

          final file = File(rawPath);
          if (!await file.exists()) {
            await db.execute('delete from local_analysis where temp_id = ?', [tempId]);
            continue;
          }
          final Uint8List bytes = await file.readAsBytes();
          final fat = FatSecretService();
          final Map<String, dynamic> fs = await fat.recognizeImage(imageBytes: bytes);
          final List<Map<String, dynamic>> detected = _extractDetectedItemsFromFatSecret(fs);
          await MealPhotoService().updateDetectedItems(id: tempId, detectedItems: detected);
          AppEvents.instance.emitPhotoAnalyzed(tempId);
          await db.execute('delete from local_analysis where temp_id = ?', [tempId]);
        } catch (e) {
          // deneme sayısını artır
          final int attempts = (r['attempts'] as int? ?? 0) + 1;
          await db.execute('update local_analysis set attempts = ? where temp_id = ?', [attempts, tempId]);
          if (kDebugMode) {
            debugPrint('Analysis retry scheduled for $tempId: $e');
          }
        }
      }
    } catch (_) {}
  }

  Future<String> saveRawBytesToFile(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    final String path = '${dir.path}/meal_raw_$id.jpg';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }

  List<Map<String, dynamic>> _extractDetectedItemsFromFatSecret(Map<String, dynamic> fs) {
    List<Map<String, dynamic>> out = [];
    List? tryList(dynamic v) => v is List ? v : null;
    Map<String, dynamic>? tryMap(dynamic v) => v is Map<String, dynamic> ? v : null;

    final List? items = tryList(fs['recognized_foods']) ??
        tryList(fs['predictions']) ??
        tryList(fs['results']) ??
        tryList(fs['food_response']);
    if (items != null) {
      for (final raw in items) {
        final m = tryMap(raw) ?? const {};
        final food = tryMap(m['food']);
        final eaten = tryMap(m['eaten']);
        final String name = (m['food_entry_name'] ?? eaten?['food_name_singular'] ?? food?['food_name'] ?? m['label'] ?? m['name'] ?? '').toString();
        final dynamic confRaw = (m['confidence'] ?? m['score'] ?? food?['confidence']);
        final double conf = confRaw is num ? confRaw.toDouble() : 0.0;
        Map<String, dynamic>? nutrition;
        final nutritionData = tryMap(m['total_nutritional_content']) ?? 
                              tryMap(eaten?['total_nutritional_content']) ??
                              tryMap(food?['nutrition']);
        if (nutritionData != null) {
          double parseNum(dynamic v) {
            if (v == null) return 0.0;
            if (v is num) return v.toDouble();
            if (v is String) {
              final match = RegExp(r'(\d+\.?\d*)').firstMatch(v);
              if (match != null) return double.tryParse(match.group(1) ?? '0') ?? 0.0;
            }
            return 0.0;
          }
          nutrition = {
            'calories': parseNum(nutritionData['calories']),
            'protein': parseNum(nutritionData['protein']),
            'carbohydrate': parseNum(nutritionData['carbohydrate'] ?? nutritionData['carbs']),
            'fat': parseNum(nutritionData['fat']),
          };
        }
        if (name.isNotEmpty) {
          out.add({'name': name, 'confidence': conf, if (nutrition != null) 'nutrition': nutrition});
        }
      }
      out.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    }
    return out;
  }
}


