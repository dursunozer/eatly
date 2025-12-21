import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/consent_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';

class LoginViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _consentService = locator<ConsentService>();
  final _navigationService = locator<NavigationService>();
  
  bool isBusySignIn = false;
  bool isBusyGoogle = false;
  String? lastError;
  String? lastUid;
  bool requirePolicyUpdate = false;
  bool requireOnboarding = false;

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
      
      // Onboarding kontrolü
      try {
        requireOnboarding = !(await ProfileService.isOnboardingCompleted());
      } catch (_) {
        requireOnboarding = false;
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

  Future<bool> signInWithGoogle() async {
    isBusyGoogle = true;
    notifyListeners();
    try {
      final uid = await _authService.signInWithGoogle();
      lastUid = uid;
      lastError = null;
      if (uid == null) return false;
      
      // Politika versiyon kontrolü
      try {
        requirePolicyUpdate = !(await _consentService.hasAcceptedCurrentPolicy());
      } catch (_) {
        requirePolicyUpdate = false;
      }
      
      // Onboarding kontrolü
      try {
        requireOnboarding = !(await ProfileService.isOnboardingCompleted());
      } catch (_) {
        requireOnboarding = false;
      }
      
      return true;
    } on AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = e.toString();
      return false;
    } finally {
      isBusyGoogle = false;
      notifyListeners();
    }
  }

  void goToSignUp() {
    // Önce sayfayı değiştir (hızlı geçiş)
    _navigationService.navigateToOnboardingView();
    // Arka planda anonim oturum başlat
    _authService.signInAnonymously().catchError((_) {});
  }
}
