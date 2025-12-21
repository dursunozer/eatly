import 'package:stacked/stacked.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eatly/app/app.locator.dart';
import 'package:eatly/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/services/profile_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  Future runStartupLogic() async {
    // Splash screen için kısa bekleme
    await Future.delayed(const Duration(seconds: 2));

    // Oturum kontrolü
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;

    if (session == null || user == null) {
      // Oturum yok -> Welcome Page'e yönlendir
      _navigationService.clearStackAndShow(Routes.welcomeView);
      return;
    }

    // Oturum var -> Onboarding kontrolü
    try {
      final isOnboardingCompleted = await ProfileService.isOnboardingCompleted();
      if (!isOnboardingCompleted) {
        _navigationService.clearStackAndShow(Routes.onboardingView);
        return;
  }
    } catch (_) {
      // Hata durumunda onboarding'e yönlendir (güvenli taraf)
      _navigationService.clearStackAndShow(Routes.onboardingView);
      return;
    }

    // Her şey tamam -> Ana sayfaya yönlendir
    _navigationService.clearStackAndShow(Routes.mainView);
  }
}
