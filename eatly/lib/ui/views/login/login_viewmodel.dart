import 'package:stacked/stacked.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class LoginViewModel extends BaseViewModel {
  bool isBusySignIn = false;
  String? lastError;
  String? lastUid;

  Future<bool> signIn(String email, String password) async {
    isBusySignIn = true;
    notifyListeners();
    try {
      final uid = await AuthService.signInWithPassword(
        email: email,
        password: password,
      );
      lastUid = uid;
      lastError = null;
      return uid != null;
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
