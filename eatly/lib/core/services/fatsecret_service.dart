import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/env.dart';

class FatSecretService {
  final Dio _dio;

  FatSecretService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));

  Future<String> _getAccessTokenForScope(String? scope) async {
    final String basicAuth = base64Encode(utf8.encode(
      '${EnvConfig.fatSecretClientId}:${EnvConfig.fatSecretClientSecret}',
    ));

    String buildBody(String? scope) {
      if (scope == null || scope.isEmpty) {
        return 'grant_type=client_credentials';
      }
      return 'grant_type=client_credentials&scope=${Uri.encodeQueryComponent(scope)}';
    }

    Future<Response> requestToken(String? scope) {
      return _dio.post(
        EnvConfig.fatSecretTokenUrl,
        data: buildBody(scope),
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Basic $basicAuth',
          },
        ),
      );
    }

    Response response;
    try {
      response = await requestToken(scope);
    } on DioException catch (e) {
      final dataStr = e.response?.data?.toString() ?? '';
      if (dataStr.contains('invalid_scope')) {
        // Scopesiz dene
        response = await requestToken(null);
      } else {
        rethrow;
      }
    }

    if (response.statusCode != 200) {
      throw Exception('FatSecret token alınamadı: ${response.statusCode} ${response.data}');
    }

    final Map<String, dynamic> json = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : jsonDecode(response.data as String) as Map<String, dynamic>;
    final accessToken = json['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('FatSecret access_token boş döndü');
    }
    return accessToken;
  }

  Future<Map<String, dynamic>> recognizeImage({
    required Uint8List imageBytes,
    String? region,
    String? language,
    bool includeFoodData = true,
  }) async {
    // Flutter Web'de çoğu üçüncü parti API CORS nedeniyle doğrudan çağrıya izin vermez.
    if (kIsWeb && (EnvConfig.fatSecretProxyUrl.isEmpty)) {
      throw Exception('Web ortamında doğrudan çağrı CORS tarafından engelleniyor. Bir proxy tanımlayın.');
    }
    final String imageB64 = base64Encode(imageBytes);

    final Map<String, dynamic> payload = {
      'image_b64': imageB64,
      // Daha iyi tanıma için dil EN ile A/B test; bölgeyi opsiyonel bırak
      'region': region ?? EnvConfig.fatSecretRegion,
      'language': language ?? 'en',
      'include_food_data': includeFoodData,
    };

    final String url = (kIsWeb && EnvConfig.fatSecretProxyUrl.isNotEmpty)
        ? EnvConfig.fatSecretProxyUrl
        : EnvConfig.fatSecretImageRecognitionUrl;

    // Denenecek scope sıralaması
    final List<String?> scopesToTry = <String?>[
      EnvConfig.fatSecretScope,
      'premier image-recognition',
      'image-recognition',
      'premier',
      null,
    ].where((s) => s == null || (s as String).trim().isNotEmpty).toList();

    DioException? lastError;
    for (final String? scope in scopesToTry) {
      try {
        final String token = await _getAccessTokenForScope(scope);
        final Response response = await _dio.post(
          url,
          data: payload,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          if (response.data is Map<String, dynamic>) {
            return response.data as Map<String, dynamic>;
          }
          return jsonDecode(response.data as String) as Map<String, dynamic>;
        }

        final bodyStr = response.data?.toString() ?? '';
        if ((response.statusCode == 401 || response.statusCode == 403) && bodyStr.contains('Missing scope')) {
          // sıradaki scope ile tekrar dene
          continue;
        }
        throw Exception('FatSecret image recognition hata: ${response.statusCode} ${response.data}');
      } on DioException catch (e) {
        lastError = e;
        final dataStr = e.response?.data?.toString() ?? '';
        if ((e.response?.statusCode == 401 || e.response?.statusCode == 403) && dataStr.contains('Missing scope')) {
          continue;
        }
        rethrow;
      }
    }

    if (lastError != null) {
      throw lastError!;
    }
    throw Exception('FatSecret çağrısı başarısız (scope denemeleri tükendi)');
  }
}


