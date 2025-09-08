import 'package:stacked/stacked.dart';
import '../../../core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/profile_service.dart';

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
  }) async {
    setBusy(true);
    try {
      if (email.trim().isEmpty || password.length < 6) {
        return 'Geçerli bir e‑posta ve en az 6 haneli şifre girin.';
      }

      // Kullanıcıyı oluştur ve mümkünse oturumu aç
      String? uid = await AuthService.signUpWithPassword(
        email: email,
        password: password,
        emailRedirectTo: null,
      );

      // Bazı ayarlarda signUp sonrası session oluşmayabilir; tekrar giriş dene
      uid ??= await AuthService.signInWithPassword(email: email, password: password);
      // Oturumun gerçekten hazır olmasını bekle (RLS için auth.uid() gerekecek)
      await Future.delayed(const Duration(milliseconds: 250));

      if (uid != null) {
        await ProfileService.upsertProfile(
          uid: uid,
          displayName: displayName,
          age: age,
          weight: weight,
          height: height,
          gender: gender,
          waistCm: waistCm,
          hipCm: hipCm,
        );
      } else {
        return 'Kullanıcı oluşturuldu ancak oturum açılamadı. Lütfen giriş yapmayı deneyin.';
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
