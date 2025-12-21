import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/services/auth_service.dart';

class WelcomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  /// Giriş yap sayfasına git
  void navigateToLogin() {
    _navigationService.navigateTo(Routes.loginView);
  }

  /// Anonim oturum başlat ve onboarding'e git
  void startOnboarding() {
    // Önce sayfayı hızlıca değiştir
    _navigationService.clearStackAndShow(Routes.onboardingView);
    // Arka planda anonim oturum başlat
    _authService.signInAnonymously().catchError((_) {});
  }

  /// Kayıt ol sayfasına git (geriye uyumluluk için)
  void navigateToSignup() {
    startOnboarding();
  }
}

