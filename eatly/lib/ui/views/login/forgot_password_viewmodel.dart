import 'package:stacked/stacked.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/app.locator.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  Future<bool> sendReset(String email) async {
    setBusy(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (_) {
      return false;
    } finally {
      setBusy(false);
    }
  }
}
