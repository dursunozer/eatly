class EnvConfig {
  // Cloud Functions HTTPS endpoint URL (proxy). Örn:
  // https://<region>-<project>.cloudfunctions.net/visionProxy
  static const String visionProxyEndpoint =
      'https://hardrada-eatly-backend.hf.space/api/vision/analyze';

  // FatSecret OAuth2 Client Credentials - SADECE DENEME İÇİN!
  // Uyarı: client_secret'i mobil uygulamaya gömmek güvenli değildir.
  // Geçici denemelerde kullanılmalıdır; prod için proxy/backend önerilir.
  static const String fatSecretClientId = '3bb20f36a6924069821d78828e9b85be';
  static const String fatSecretClientSecret =
      '43c50733046643949f0766737879dbdd';
  static const String fatSecretTokenUrl =
      'https://oauth.fatsecret.com/connect/token';
  static const String fatSecretImageRecognitionUrl =
      'https://platform.fatsecret.com/rest/image-recognition/v2';
  static const String fatSecretScope = 'image-recognition';
  static const String fatSecretRegion = 'tr';
  static const String fatSecretLanguage = 'tr';
  // Opsiyonel: Web için CORS proxy (boş bırakılırsa kullanılmaz)
  static const String fatSecretProxyUrl = '';
}
