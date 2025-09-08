import 'package:stacked/stacked.dart';
import '../../../core/services/auth_service.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  Future<bool> sendReset(String email) async {
    setBusy(true);
    try {
      await AuthService.sendPasswordResetEmail(email);
      return true;
    } catch (_) {
      return false;
    } finally {
      setBusy(false);
    }
  }
}
