import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_service.dart';

class HuggingFaceService {
  final ApiService _apiService = ApiService();
  
  // HuggingFace API endpoint'leri
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  static const String _imageClassificationModel = 'google/vit-base-patch16-224';
  static const String _objectDetectionModel = 'facebook/detr-resnet-50';
  
  // API anahtarı - gerçek projede environment variable'dan alınmalı
  static const String _apiKey = 'YOUR_HUGGINGFACE_API_KEY';
  
  Future<Map<String, dynamic>> classifyFood(Uint8List imageBytes) async {
    try {
      final response = await _apiService.dio.post(
        '$_baseUrl/$_imageClassificationModel',
        data: imageBytes,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/octet-stream',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': 'API request failed with status: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _handleHuggingFaceError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> detectObjects(Uint8List imageBytes) async {
    try {
      final response = await _apiService.dio.post(
        '$_baseUrl/$_objectDetectionModel',
        data: imageBytes,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/octet-stream',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': 'API request failed with status: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _handleHuggingFaceError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> analyzeNutrition(String foodName) async {
    // Bu method için özel bir nutrition analysis modeli kullanılabilir
    // Şimdilik basit bir mock response dönüyoruz
    
    await Future.delayed(const Duration(seconds: 1)); // API call simülasyonu
    
    // Mock nutrition data
    final mockNutrition = _getMockNutritionData(foodName);
    
    return {
      'success': true,
      'data': mockNutrition,
    };
  }
  
  String _handleHuggingFaceError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      switch (statusCode) {
        case 400:
          return 'Geçersiz istek - resim formatı desteklenmiyor olabilir';
        case 401:
          return 'API anahtarı geçersiz';
        case 403:
          return 'API erişimi reddedildi';
        case 429:
          return 'API rate limit aşıldı, lütfen daha sonra tekrar deneyin';
        case 500:
          return 'HuggingFace sunucu hatası';
        case 503:
          return 'Model şu anda yüklenemiyor, lütfen daha sonra tekrar deneyin';
        default:
          return 'API hatası: $statusCode';
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Bağlantı zaman aşımına uğradı';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'İnternet bağlantısı hatası';
    } else {
      return 'Bilinmeyen hata: ${error.message}';
    }
  }
  
  Map<String, dynamic> _getMockNutritionData(String foodName) {
    // Basit mock data - gerçek projede gerçek nutrition database kullanılmalı
    final mockData = {
      'apple': {
        'calories': 52,
        'protein': 0.3,
        'carbs': 14,
        'fat': 0.2,
        'fiber': 2.4,
        'sugar': 10,
      },
      'banana': {
        'calories': 89,
        'protein': 1.1,
        'carbs': 23,
        'fat': 0.3,
        'fiber': 2.6,
        'sugar': 12,
      },
      'bread': {
        'calories': 265,
        'protein': 9,
        'carbs': 49,
        'fat': 3.2,
        'fiber': 2.7,
        'sugar': 5,
      },
      'egg': {
        'calories': 155,
        'protein': 13,
        'carbs': 1.1,
        'fat': 11,
        'fiber': 0,
        'sugar': 1.1,
      },
    };
    
    final lowerFoodName = foodName.toLowerCase();
    for (final key in mockData.keys) {
      if (lowerFoodName.contains(key)) {
        return mockData[key]!;
      }
    }
    
    // Default nutrition data
    return {
      'calories': 100,
      'protein': 5,
      'carbs': 15,
      'fat': 3,
      'fiber': 2,
      'sugar': 5,
    };
  }
  
  // Model durumunu kontrol et
  Future<bool> isModelAvailable(String modelName) async {
    try {
      final response = await _apiService.dio.get(
        '$_baseUrl/$modelName',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
