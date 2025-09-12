import 'package:stacked/stacked.dart';
import '../../../core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/policy_config.dart';
// Profil oluşturmayı giriş sonrasına bırakıyoruz; burada kullanmıyoruz

class SignupViewModel extends BaseViewModel {
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
    setBusy(true);
    try {
      if (email.trim().isEmpty || password.length < 6) {
        return 'Geçerli bir e‑posta ve en az 6 haneli şifre girin.';
      }

      // Kullanıcıyı oluştur (e‑posta doğrulaması gerektiren projelerde
      // burada oturum açmaya çalışmayacağız)
      final String? uid = await AuthService.signUpWithPassword(
        email: email,
        password: password,
        emailRedirectTo: null,
        metadata: {
          'display_name': displayName,
          if (age != null) 'age': age,
          if (weight != null) 'weight': weight,
          if (height != null) 'height': height,
          if (gender != null) 'gender': gender,
          if (waistCm != null) 'waist_cm': waistCm,
          if (hipCm != null) 'hip_cm': hipCm,
          // Onaylar: ilk oturum yoksa RLS nedeniyle insert düşebilir; metadata yedek olarak tutulur
          'kvkk_accepted': kvkkAccepted,
          'healthdata_accepted': healthAccepted,
          'policy_version': PolicyConfig.policyVersion,
        },
      );
      // Bu aşamada profil upsert etmiyoruz; giriş sonrası (email onaylandıktan sonra)
      // profil ekranı açıldığında eksikse oluşturulacak.
      if (uid == null) return 'Kullanıcı oluşturulamadı. Lütfen tekrar deneyin.';

      // KVKK ve sağlık verisi açık rızalarını kaydet
      try {
        final client = Supabase.instance.client;
        await client.from('user_consents').insert({
          'user_id': client.auth.currentUser?.id ?? uid,
          'kvkk_accepted': kvkkAccepted,
          'healthdata_accepted': healthAccepted,
          'policy_version': PolicyConfig.policyVersion,
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (e) {
        // Onay kaydı zorunlu değilse sessiz devam; ancak istenirse hata döndürülebilir
      }
      return null;
    } on AuthException catch (e) {
      final msg = (e.message ?? '').toLowerCase();
      if (msg.contains('already') || msg.contains('registered') || msg.contains('exists')) {
        return 'Bu e‑posta zaten kayıtlı. Lütfen giriş yapın veya "Şifremi unuttum" seçeneğini kullanın.';
      }
      return e.message;
    } catch (e) {
      return 'Profil kaydı başarısız: $e';
    } finally {
      setBusy(false);
    }
  }
}
