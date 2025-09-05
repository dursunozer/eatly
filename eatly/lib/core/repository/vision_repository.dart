import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../api/vision_api_client.dart';
import '../models/vision_api/vision_request.dart';
import '../models/vision_api/vision_response.dart';

class VisionRepository {
  final VisionApiClient _client;

  VisionRepository._(this._client);

  factory VisionRepository({String? baseUrl}) {
    final dio = Dio();
    if (baseUrl != null && baseUrl.isNotEmpty) {
      dio.options.baseUrl = baseUrl;
    }
    return VisionRepository._(VisionApiClient(dio));
  }

  Future<VisionApiResponse> analyzeBytes({
    required Uint8List imageBytes,
    required String apiKey,
  }) async {
    final base64Image = base64Encode(imageBytes);
    final request = VisionApiRequest(requests: [
      RequestItem(
        image: ImageContent(content: base64Image),
        features: [
          Feature(type: 'LABEL_DETECTION', maxResults: 10),
          Feature(type: 'OBJECT_LOCALIZATION'),
        ],
      ),
    ]);

    return _client.annotateImage(request, apiKey);
  }
}



