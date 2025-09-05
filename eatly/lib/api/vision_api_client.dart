// lib/api/vision_api_client.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:eatly/core/models/vision_api/vision_request.dart';
import 'package:eatly/core/models/vision_api/vision_response.dart';

part 'vision_api_client.g.dart'; // retrofit_generator bu dosyayı üretecek

const String VISION_BASE_URL =
    'https://vision.googleapis.com/v1/'; // Vision AI API'sinin temel URL'i
const String VISION_API_KEY =
    "AIzaSyBPwumSTFWb_DMlXFH0PqC-SyHogdic71E"; // API anahtarınızı buraya yapıştırın

@RestApi(baseUrl: VISION_BASE_URL)
abstract class VisionApiClient {
  factory VisionApiClient(Dio dio, {String baseUrl}) = _VisionApiClient;

  @POST('images:annotate') // API endpoint'i
  Future<VisionApiResponse> annotateImage(
    @Body() VisionApiRequest request,
    @Query('key')
    String apiKey, // API anahtarını query parametresi olarak gönder
  );
}
