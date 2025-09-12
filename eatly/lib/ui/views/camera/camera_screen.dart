import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/vision_models.dart' as vr;
import '../../../core/models/vision_api/vision_request.dart';
import '../../../core/models/vision_api/vision_response.dart';
import '../../../api/vision_api_client.dart';
import '../../../core/services/photo_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../core/services/powersync_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

const String VISION_API_KEY = "AIzaSyBPwumSTFWb_DMlXFH0PqC-SyHogdic71E";

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  final dio = Dio();

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0], // Varsayılan olarak ilk kamerayı kullan
          ResolutionPreset.low, // dosya boyutunu düşür
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Kamera başlatma hatası: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kamera başlatma hatası: $e')));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();
      _navigateToAnalysis(image); // XFile gönderiliyor
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fotoğraf çekilemedi: $e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (image != null) {
        _navigateToAnalysis(image); // XFile gönderiliyor
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Resim seçilemedi: $e')));
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

  Future<void> _navigateToAnalysis(XFile imageXFile) async {
    // Parametre artık XFile
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            const Text('Fotoğraf analiz ediliyor...'),
            const SizedBox(height: 8),
            Text(
              'Besinler tespit ediliyor',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );

    try {
      final Uint8List rawBytes = await imageXFile.readAsBytes();
      _printBytesSize(rawBytes, 'Raw image');
      final Uint8List bytes = await _compressMobile(rawBytes);
      _printBytesSize(bytes, 'Compressed image');
      final String base64Image = base64Encode(
        bytes,
      ); // Görüntüyü Base64'e çevir

      final String url = Uri.https(
        'vision.googleapis.com',
        '/v1/images:annotate',
        {'key': VISION_API_KEY},
      ).toString();

      // Retrofit istemcisiyle çağrı
      final client = VisionApiClient(dio, baseUrl: VISION_BASE_URL);
      final request = VisionApiRequest(
        requests: [
          RequestItem(
            image: ImageContent(content: base64Image),
            features: [
              Feature(type: 'LABEL_DETECTION', maxResults: 10),
              Feature(type: 'OBJECT_LOCALIZATION'),
            ],
          ),
        ],
      );

      final VisionApiResponse apiRes = await client.annotateImage(
        request,
        VISION_API_KEY,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (apiRes.responses.isNotEmpty) {
        final first = apiRes.responses.first;
        final vr.VisionResult visionResult = vr.VisionResult(
          labels: first.labels ?? <vr.VisionLabel>[],
          objects: first.objects ?? <vr.VisionObject>[],
        );
        _showAnalysisResults(bytes, visionResult);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vision AI API\'den geçerli yanıt alınamadı.'),
          ),
        );
      }
    } on DioException catch (e) {
      // <<< Sadece Dio hatalarını yakala
      if (!mounted) return;
      Navigator.pop(context);
      String errorMessage = 'Ağ Hatası: ';
      if (e.response != null) {
        // API'den bir yanıt (hata kodu ile) geldiyse
        errorMessage +=
            '${e.response?.statusCode} - ${e.response?.statusMessage}';
        if (e.response?.data != null) {
          // Yanıtın içinde hata verisi varsa
          errorMessage += '\nDetay: ${e.response?.data}';
        }
      } else {
        // Yanıt gelmediyse (ağ bağlantısı yok, timeout vb.)
        errorMessage += e.message ?? 'Bilinmeyen bir Dio hatası.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Analiz hatası: $errorMessage')));
      print('Analiz hatası (Dio): $errorMessage');
    } catch (e) {
      // <<< Diğer genel hataları yakala
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Genel analiz hatası: $e')));
      print('Genel analiz hatası: $e');
    }
  }

  // _showAnalysisResults metodu güncellendi
  void _showAnalysisResults(Uint8List imageBytes, vr.VisionResult result) {
    // Parametre File yerine Uint8List
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Tespit Edilen Besinler',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      // Image.file yerine Image.memory kullanılıyor
                      imageBytes,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Obje tespitleri varsa onları göster
                  if (result.objects.isNotEmpty)
                    ...result.objects.map(
                      (o) => _buildDetectedVisionItem(
                        o.name.toString(),
                        'Skor: ${((o.score) * 100).toStringAsFixed(0)}%',
                      ),
                    )
                  // Obje tespiti yoksa etiket tespitlerini göster
                  else if (result.labels.isNotEmpty)
                    ...result.labels
                        .take(5)
                        .map(
                          (l) => _buildDetectedVisionItem(
                            l.description.toString(),
                            'Skor: ${((l.score) * 100).toStringAsFixed(0)}%',
                          ),
                        ),
                  if (result.objects.isEmpty && result.labels.isEmpty)
                    const Text(
                      'Herhangi bir besin veya obje tespit edilemedi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Vision sonuçlarını basit JSON listelerine dönüştürelim
                        final labelJson = result.labels
                            .map(
                              (l) => {
                                'description': l.description,
                                'score': l.score,
                              },
                            )
                            .toList();
                        final objectJson = result.objects
                            .map((o) => {'name': o.name, 'score': o.score})
                            .toList();

                        // Fotoğrafı cihaz dizinine yazma: sadece mobil/desktop (web'de path_provider yok)
                        try {
                          final id = DateTime.now().millisecondsSinceEpoch
                              .toString();
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

                        // Supabase'e kaydet (online ise)
                        String savedPath;
                        try {
                          savedPath = await PhotoService.saveUserMealPhoto(
                            bytes: imageBytes,
                            labels: labelJson,
                            objects: objectJson,
                          );
                        } catch (_) {
                          savedPath = '';
                        }

                        // Doğrulama: kayıt gerçekten oluşmuş mu?
                        if (savedPath.isNotEmpty) {
                          final ok = await PhotoService.existsUserPhoto(
                            storagePath: savedPath,
                          );
                          if (!ok) {
                            throw StateError('Kayıt doğrulanamadı');
                          }
                        }

                        if (mounted) Navigator.pop(context);
                        if (!mounted) return;
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fotoğraf kaydedildi!'),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      } catch (e) {
                        if (mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Kaydetme hatası: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Kaydet'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedVisionItem(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build metodu aynı kalacak
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Fotoğraf Çek',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickFromGallery,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isInitialized && _controller != null)
            Center(child: CameraPreview(_controller!))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.flash_auto, // Flaş kontrolü
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      // Flaş kontrolü buraya eklenebilir
                    },
                  ),
                  GestureDetector(
                    onTap: _isProcessing ? null : _takePicture,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: _isProcessing
                            ? Colors.grey
                            : Colors.white.withOpacity(0.3),
                      ),
                      child: _isProcessing
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.camera,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _cameras != null && _cameras!.length > 1
                          ? Icons
                                .flip_camera_ios // Birden fazla kamera varsa çevirme ikonu
                          : Icons
                                .flip_camera_ios_outlined, // Tek kamera veya yoksa outline ikon
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _cameras != null && _cameras!.length > 1
                        ? () {
                            // Kamera değiştirme mantığı buraya eklenebilir
                            // Örneğin: _toggleCamera();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
