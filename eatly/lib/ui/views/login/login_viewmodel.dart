import 'package:stacked/stacked.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/consent_service.dart';
import '../../../app/app.locator.dart';

class LoginViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _consentService = locator<ConsentService>();
  bool isBusySignIn = false;
  String? lastError;
  String? lastUid;
  bool requirePolicyUpdate = false;

  Future<bool> signIn(String email, String password) async {
    isBusySignIn = true;
    notifyListeners();
    try {
      final uid = await _authService.signInWithPassword(
        email: email,
        password: password,
      );
      lastUid = uid;
      lastError = null;
      if (uid == null) return false;
      // Politika versiyon kontrolü
      try {
        requirePolicyUpdate = !(await _consentService.hasAcceptedCurrentPolicy());
      } catch (_) {
        requirePolicyUpdate = false;
      }
      return true;
    } on AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = 'Beklenmedik hata: $e';
      return false;
    } finally {
      isBusySignIn = false;
      notifyListeners();
    }
  }
}
