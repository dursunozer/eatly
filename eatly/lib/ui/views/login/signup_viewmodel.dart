import 'package:stacked/stacked.dart';
import '../../../core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/policy_config.dart';
import '../../../app/app.locator.dart';
import '../../../core/services/profile_service.dart';

class SignupViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();

  /// Basitleştirilmiş kayıt - sadece temel bilgiler
  /// Yaş, kilo, boy gibi bilgiler onboarding'de alınacak
  Future<String?> signUpSimple({
    required String email,
    required String password,
    required String displayName,
    required bool kvkkAccepted,
    required bool healthAccepted,
  }) async {
    setBusy(true);
    try {
      if (email.trim().isEmpty || password.length < 6) {
        return 'Geçerli bir e‑posta ve en az 6 haneli şifre girin.';
      }

      // Kullanıcıyı oluştur
      final String? uid = await _authService.signUpWithPassword(
        email: email,
        password: password,
        emailRedirectTo: null,
        metadata: {
          'display_name': displayName,
          'kvkk_accepted': kvkkAccepted,
          'healthdata_accepted': healthAccepted,
          'policy_version': PolicyConfig.policyVersion,
        },
      );

      if (uid == null) {
        return 'Kullanıcı oluşturulamadı. Lütfen tekrar deneyin.';
      }

      // Profil kaydı oluştur
      try {
        await ProfileService.upsertProfile(
          uid: uid,
          displayName: displayName,
        );
      } catch (e) {
        // Profil kaydı başarısız olsa bile devam et
        // Onboarding'de tekrar denenecek
      }

      // KVKK ve sağlık verisi açık rızalarını kaydet
      try {
        final client = Supabase.instance.client;
        await client.from('user_consents').insert({
          'user_id': uid,
          'kvkk_accepted': kvkkAccepted,
          'healthdata_accepted': healthAccepted,
          'policy_version': PolicyConfig.policyVersion,
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (e) {
        // Onay kaydı zorunlu değilse sessiz devam
      }

      return null;
    } on AuthException catch (e) {
      final msg = (e.message ?? '').toLowerCase();
      if (msg.contains('already') || msg.contains('registered') || msg.contains('exists')) {
        return 'Bu e‑posta zaten kayıtlı. Lütfen giriş yapın.';
      }
      return e.message;
    } catch (e) {
      return 'Kayıt başarısız: $e';
    } finally {
      setBusy(false);
    }
  }

  /// Eski detaylı kayıt metodu (geriye dönük uyumluluk için)
  Future<String?> signUpExtended({
    required String email,
    required String password,
    required String displayName,
    int? age,
    double? weight,
    double? height,
    String? gender,
    double? waistCm,
    double? hipCm,
    required bool kvkkAccepted,
    required bool healthAccepted,
  }) async {
    return signUpSimple(
      email: email,
      password: password,
      displayName: displayName,
      kvkkAccepted: kvkkAccepted,
      healthAccepted: healthAccepted,
    );
  }
}
