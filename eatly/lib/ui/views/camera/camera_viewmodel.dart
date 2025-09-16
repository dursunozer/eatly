import 'package:stacked/stacked.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.dart';
import '../../../core/services/vision_service.dart';
import '../../../core/models/vision_analysis.dart';
import '../../../core/models/vision_models.dart' as vr;
import '../../../core/services/photo_service.dart';
import '../../../core/services/powersync_service.dart';
import '../../../core/theme/app_theme.dart';

class CameraViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _dialogService = locator<DialogService>();
  final _photoService = locator<PhotoService>();
  
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
    _dialogService.showDialog(
      title: 'Fotoğraf analiz ediliyor...',
      description: 'Besinler tespit ediliyor',
      barrierDismissible: false,
    );
    
    try {
      final Uint8List rawBytes = await imageXFile.readAsBytes();
      _printBytesSize(rawBytes, 'Raw image');
      final Uint8List bytes = await _compressMobile(rawBytes);
      _printBytesSize(bytes, 'Compressed image');
      
      final vision = VisionService();
      final VisionAnalysis analysis = await vision.analyzeImageBytes(bytes);
      
      _dialogService.completeDialog(DialogResponse());
      await _showAnalysisResults(bytes, analysis.result, analysis.nutrition);
    } on DioException catch (e) {
      _dialogService.completeDialog(DialogResponse());
      String errorMessage = 'Ağ Hatası: ';
      if (e.response != null) {
        errorMessage += '${e.response?.statusCode} - ${e.response?.statusMessage}';
        if (e.response?.data != null) {
          errorMessage += '\nDetay: ${e.response?.data}';
        }
      } else {
        errorMessage += e.message ?? 'Bilinmeyen bir Dio hatası.';
      }
      _snackbarService.showSnackbar(
        message: 'Analiz hatası: $errorMessage',
        duration: const Duration(seconds: 3),
      );
      debugPrint('Analiz hatası (Dio): $errorMessage');
    } catch (e) {
      _dialogService.completeDialog(DialogResponse());
      _snackbarService.showSnackbar(
        message: 'Genel analiz hatası: $e',
        duration: const Duration(seconds: 3),
      );
      debugPrint('Genel analiz hatası: $e');
    }
  }
  
  Future<Uint8List> _compressMobile(Uint8List input) async {
    try {
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
      if (current.lengthInBytes > 250 * 1024) {
        current = Uint8List.fromList(
          await FlutterImageCompress.compressWithList(
            current,
            quality: 70,
            minWidth: 1024,
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
  
  Future<void> _showAnalysisResults(
    Uint8List imageBytes,
    vr.VisionResult result,
    Map<String, dynamic>? nutrition,
  ) async {
    // Basit dialog ile kullanıcıya sonuçları göster
    final response = await _dialogService.showConfirmationDialog(
      title: 'Tespit Edilen Besinler',
      description: _formatAnalysisResults(result, nutrition),
      confirmationTitle: 'Kaydet',
      cancelTitle: 'İptal',
    );
    
    if (response?.confirmed == true) {
      await _savePhoto(imageBytes, result, nutrition);
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
