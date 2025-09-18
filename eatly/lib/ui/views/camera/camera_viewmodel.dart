import 'package:stacked/stacked.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.dart';
import '../../../core/services/vision_service.dart';
import '../../../core/models/vision_analysis.dart';
import '../../../core/models/vision_models.dart' as vr;
import '../../../core/services/fatsecret_service.dart';
import '../../../core/services/photo_service.dart';
import '../../../core/services/powersync_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/meal_photo_service.dart';
import '../../../core/services/analysis_service.dart';

class CameraViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _dialogService = locator<DialogService>();
  final _photoService = locator<PhotoService>();
  final MealPhotoService _mealPhotoService = MealPhotoService();
  
  final ImagePicker _imagePicker = ImagePicker();
  final dio = Dio();
  
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  bool get hasMultipleCameras => _cameras != null && _cameras!.length > 1;
  
  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.low,
          enableAudio: false,
        );
        await _controller!.initialize();
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Kamera başlatma hatası: $e');
      _snackbarService.showSnackbar(
        message: 'Kamera başlatma hatası: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  void disposeCamera() {
    _controller?.dispose();
  }
  
  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    _isProcessing = true;
    notifyListeners();
    
    try {
      final XFile image = await _controller!.takePicture();
      await _processImage(image);
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Fotoğraf çekilemedi: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Resim seçilemedi: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  Future<void> _processImage(XFile imageXFile) async {
    try {
      debugPrint('🔄 Fotoğraf işleniyor...');
      // 1) Ham (yüksek kaliteli) baytlar - API analizine bu gidecek
      final Uint8List rawBytes = await imageXFile.readAsBytes();
      _printBytesSize(rawBytes, 'Raw image');

      // 2) Sıkıştırılmış baytlar - cihazda ve UI'da bu saklanacak/gösterilecek
      final Uint8List compressedBytes = await _compressMobile(rawBytes);
      _printBytesSize(compressedBytes, 'Compressed image');

      // 1) Fotoğrafı hemen "Son Öğünler" listesine ekle (analiz beklenmeden)
      debugPrint('📱 Yerel listeye ekleniyor...');
      final String tempId = await _mealPhotoService.addPhoto(compressedBytes);
      debugPrint('✅ Yerel listeye eklendi: $tempId');

      // 2) Ana ekrana dön ve Home'ı yenile
      debugPrint('🏠 Ana ekrana dönülüyor...');
      _navigationService.back(result: {'newPhoto': true, 'photoId': tempId});

      // 3) Arka planda: yerel kuyruğa ekle (UploaderService otomatik Supabase'e yükler)
      debugPrint('💾 Yerel kuyruğa ekleniyor...');
      await _enqueueLocalSave(compressedBytes);

      // 4) Arka planda: analiz et ve sonucu güncelle
      debugPrint('🔍 Analiz (ham kalite) başlatılıyor...');
      unawaited(_performAnalysis(tempId, rawBytes));
    } catch (e) {
      debugPrint('❌ Fotoğraf işleme hatası: $e');
      _snackbarService.showSnackbar(
        message: 'Fotoğraf işlenemedi: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // _uploadToSupabase metodu kaldırıldı - UploaderService kullanılıyor

  Future<void> _performAnalysis(String tempId, Uint8List bytes) async {
    try {
      final fat = FatSecretService();
      final Map<String, dynamic> fs = await fat.recognizeImage(imageBytes: bytes);
      final List<Map<String, dynamic>> detected = _extractDetectedItemsFromFatSecret(fs);
      await _mealPhotoService.updateDetectedItems(id: tempId, detectedItems: detected);
      debugPrint('✅ Analiz tamamlandı: ${detected.length} öğe');
      
      // Analiz tamamlandığında bildirim göster
      if (detected.isNotEmpty) {
        final preview = detected.take(3).map((e) => e['name']).join(', ');
        final more = detected.length > 3 ? ' ve ${detected.length - 3} besin daha' : '';
        _snackbarService.showSnackbar(
          message: '$preview$more tespit edildi!',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ Analiz hatası: $e');
      // Çevrimdışı veya geçici hata durumunda kuyruğa al
      try {
        final String rawPath = await AnalysisService.instance.saveRawBytesToFile(bytes);
        await AppPowerSync.instance.db.execute(
          'insert or replace into local_analysis (temp_id, raw_path, created_at) values (?, ?, ?)',
          [tempId, rawPath, DateTime.now().toIso8601String()],
        );
        // UI: ağ bekleniyor
        await _mealPhotoService.markWaitingNetwork(id: tempId, waiting: true);
        // Bağlantı gelince otomatik çalışacak; kullanıcıyı bilgilendir
        _snackbarService.showSnackbar(
          message: 'Analiz internet geldiğinde tamamlanacak',
          duration: const Duration(seconds: 3),
        );
      } catch (_) {
        _snackbarService.showSnackbar(
          message: 'Analiz tamamlanamadı: $e',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _enqueueLocalSave(Uint8List imageBytes) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final dir = await getApplicationDocumentsDirectory();
      final String filePath = '${dir.path}/meal_$id.jpg';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes, flush: true);
      printFileSize(file, 'Saved local file');

      await AppPowerSync.instance.db.execute(
        'insert into local_photos (id, local_path, taken_at, is_synced) values (?, ?, ?, ?)',
        [id, filePath, DateTime.now().toIso8601String(), 0],
      );
    } catch (_) {
      // Web veya destek yoksa sessizce geç
    }
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
        
        // Besin değerlerini çıkar
        final nutritionData = tryMap(m['total_nutritional_content']) ?? 
                             tryMap(eaten?['total_nutritional_content']) ??
                             tryMap(food?['nutrition']);
        
        Map<String, dynamic>? nutrition;
        if (nutritionData != null) {
          nutrition = {
            'calories': _parseNumber(nutritionData['calories']),
            'protein': _parseNumber(nutritionData['protein']),
            'carbohydrate': _parseNumber(nutritionData['carbohydrate'] ?? nutritionData['carbs']),
            'fat': _parseNumber(nutritionData['fat']),
          };
        }
        
        if (name.isNotEmpty) {
          out.add({
            'name': name, 
            'confidence': conf,
            if (nutrition != null) 'nutrition': nutrition,
          });
        }
      }
      out.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    }
    return out;
  }
  
  double _parseNumber(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      // "45.2g" gibi string'lerdeki sayıları çıkar
      final match = RegExp(r'(\d+\.?\d*)').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(1) ?? '0') ?? 0.0;
      }
    }
    return 0.0;
  }
  
  Future<Uint8List> _compressMobile(Uint8List input) async {
    try {
      // UI ve depolama için makul boyut: ~300-600KB civarı hedefle
      Uint8List current = Uint8List.fromList(
        await FlutterImageCompress.compressWithList(
          input,
          quality: 80,
          minWidth: 1280,
          format: CompressFormat.jpeg,
          autoCorrectionAngle: true,
          keepExif: false,
        ),
      );
      if (current.lengthInBytes > 600 * 1024) {
        current = Uint8List.fromList(
          await FlutterImageCompress.compressWithList(
            current,
            quality: 72,
            minWidth: 1280,
            format: CompressFormat.jpeg,
            autoCorrectionAngle: true,
            keepExif: false,
          ),
        );
      }
      return current;
    } catch (_) {
      return input;
    }
  }
  
  void _printBytesSize(Uint8List data, String label) {
    final bytes = data.lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    if (kDebugMode) {
      debugPrint(
        '$label: $bytes bytes (${kb.toStringAsFixed(2)} KB / ${mb.toStringAsFixed(2)} MB)',
      );
    }
  }
  
  void printFileSize(File file, String label) {
    try {
      final bytes = file.lengthSync();
      final kb = bytes / 1024;
      final mb = kb / 1024;
      if (kDebugMode) {
        debugPrint(
          '$label: $bytes bytes (${kb.toStringAsFixed(2)} KB / ${mb.toStringAsFixed(2)} MB)',
        );
      }
    } catch (_) {}
  }
  
  // Artık kullanılmayan dialog metotları kaldırıldı

  String _formatFatSecretResults(Map<String, dynamic> fs) {
    try {
      // 1) Bilinen şemalar: recognized_foods, predictions, results
      final buffer = StringBuffer();

      List? tryList(dynamic v) => v is List ? v : null;
      Map<String, dynamic>? tryMap(dynamic v) => v is Map<String, dynamic> ? v : null;

      List? items = tryList(fs['recognized_foods']) ?? tryList(fs['predictions']) ?? tryList(fs['results']) ?? tryList(fs['food_response']);
      if (items != null && items.isNotEmpty) {
        buffer.writeln('Tespit edilen yiyecekler:');
        for (final raw in items.take(5)) {
          final m = tryMap(raw) ?? const {};
          final food = tryMap(m['food']);
          final eaten = tryMap(m['eaten']);
          final name = (m['food_entry_name'] ?? eaten?['food_name_singular'] ?? food?['food_name'] ?? m['label'] ?? m['name'] ?? '').toString();
          final conf = (m['confidence'] ?? m['score'] ?? food?['confidence'] ?? '').toString();
          // Besin özetini göster
          final nutrition = tryMap(m['total_nutritional_content']) ?? tryMap(eaten?['total_nutritional_content']);
          buffer.writeln('• ${name.isEmpty ? 'Bilinmiyor' : name} ${conf.isNotEmpty ? '($conf)' : ''}');
          if (nutrition != null) {
            final cal = nutrition['calories'];
            final prot = nutrition['protein'];
            final carbs = nutrition['carbohydrate'] ?? nutrition['carbs'];
            final fat = nutrition['fat'];
            buffer.writeln('  kcal: $cal, P: $prot, C: $carbs, F: $fat');
          }
        }
        return buffer.toString();
      }

      // 2) Tanımadığımız şema: Ham JSON göster
      return const JsonEncoder.withIndent('  ').convert(fs);
    } catch (_) {
      return 'Sonuçlar gösterilemiyor';
    }
  }
  
  String _formatAnalysisResults(vr.VisionResult result, Map<String, dynamic>? nutrition) {
    String text = '';
    
    if (result.objects.isNotEmpty) {
      text += 'Tespit edilen objeler:\n';
      for (final obj in result.objects.take(3)) {
        text += '• ${obj.name} (${(obj.score * 100).toInt()}%)\n';
      }
    } else if (result.labels.isNotEmpty) {
      text += 'Tespit edilen etiketler:\n';
      for (final label in result.labels.take(3)) {
        text += '• ${label.description} (${(label.score * 100).toInt()}%)\n';
      }
    }
    
    if (nutrition != null && nutrition.isNotEmpty) {
      text += '\nBesin değerleri mevcut.';
    }
    
    return text.isEmpty ? 'Herhangi bir besin tespit edilemedi.' : text;
  }
  
  Future<void> _savePhoto(
    Uint8List imageBytes,
    vr.VisionResult result,
    Map<String, dynamic>? nutrition,
  ) async {
    try {
      // Vision sonuçlarını basit JSON listelerine dönüştür
      final labelJson = result.labels
          .map((l) => {
                'description': l.description,
                'score': l.score,
              })
          .toList();
      final objectJson = result.objects
          .map((o) => {'name': o.name, 'score': o.score})
          .toList();
      
      // Fotoğrafı cihaz dizinine yaz
      try {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final dir = await getApplicationDocumentsDirectory();
        final String filePath = '${dir.path}/meal_$id.jpg';
        final file = File(filePath);
        await file.writeAsBytes(imageBytes, flush: true);
        printFileSize(file, 'Saved local file');
        
        await AppPowerSync.instance.db.execute(
          'insert into local_photos (id, local_path, taken_at, is_synced) values (?, ?, ?, ?)',
          [id, filePath, DateTime.now().toIso8601String(), 0],
        );
      } catch (_) {
        // Web veya platform desteği yoksa sessizce devam et
      }
      
      // Supabase'e kaydet
      String savedPath;
      try {
        savedPath = await _photoService.saveUserMealPhoto(
          bytes: imageBytes,
          labels: labelJson,
          objects: objectJson,
          nutrition: nutrition,
        );
      } catch (_) {
        savedPath = '';
      }
      
      // Doğrulama
      if (savedPath.isNotEmpty) {
        final ok = await _photoService.existsUserPhoto(
          storagePath: savedPath,
        );
        if (!ok) {
          throw StateError('Kayıt doğrulanamadı');
        }
      }
      
      _snackbarService.showSnackbar(
        message: 'Fotoğraf kaydedildi!',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Kaydetme hatası: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  void toggleFlash() {
    // Flash kontrolü buraya eklenebilir
  }
  
  void switchCamera() {
    if (_cameras != null && _cameras!.length > 1) {
      // Kamera değiştirme mantığı
      // Mevcut kameranın index'ini bul ve diğerine geç
    }
  }
}
