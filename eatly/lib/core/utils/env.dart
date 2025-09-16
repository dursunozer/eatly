class EnvConfig {
  // Cloud Functions HTTPS endpoint URL (proxy). Örn:
  // https://<region>-<project>.cloudfunctions.net/visionProxy
  static const String visionProxyEndpoint = 'https://hardrada-eatly-backend.hf.space/api/vision/analyze';

  // FatSecret OAuth2 Client Credentials - SADECE DENEME İÇİN!
  // Uyarı: client_secret'i mobil uygulamaya gömmek güvenli değildir.
  // Geçici denemelerde kullanılmalıdır; prod için proxy/backend önerilir.
  static const String fatSecretClientId = 'f0051048ba5f4402bfe56c0961d4e1b3';
  static const String fatSecretClientSecret = '81b8a69feb1045178193d796abaa6742';
  static const String fatSecretTokenUrl = 'https://oauth.fatsecret.com/connect/token';
  static const String fatSecretImageRecognitionUrl = 'https://platform.fatsecret.com/rest/image-recognition/v2';
  static const String fatSecretScope = 'image-recognition';
  static const String fatSecretRegion = 'tr';
  static const String fatSecretLanguage = 'tr';
  // Opsiyonel: Web için CORS proxy (boş bırakılırsa kullanılmaz)
  static const String fatSecretProxyUrl = '';
}


