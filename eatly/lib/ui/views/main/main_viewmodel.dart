import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../camera/camera_view.dart';
import '../../views/login/consent_update_view.dart';
import '../../../core/services/consent_service.dart';

class MainViewModel extends BaseViewModel {
  final _nav = locator<NavigationService>();
  final _consentService = locator<ConsentService>();

  int currentIndex = 0;

  void onTabSelected(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future<void> goToCamera() async {
    final result = await _nav.navigateToCameraScreen();
    // Kamera sayfasından sonuç dönerse ana sayfaya dön
    if (result != null) {
      // Giriş (Home) sekmesine dön
      currentIndex = 0;
      notifyListeners();
    }
  }

  Future<void> ensurePolicyUpToDate() async {
    try {
      final ok = await _consentService.hasAcceptedCurrentPolicy();
      if (!ok) {
        await _nav.navigateToView(const ConsentUpdateView());
      }
    } catch (_) {}
  }
}