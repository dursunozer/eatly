import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../app/app.locator.dart';
import '../../../core/config/policy_config.dart';
import '../../../core/services/consent_service.dart';

class ConsentUpdateViewModel extends BaseViewModel {
  final _consentService = locator<ConsentService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  
  bool _acceptKvkk = false;
  bool _acceptHealth = false;
  
  bool get acceptKvkk => _acceptKvkk;
  bool get acceptHealth => _acceptHealth;
  String get policyVersion => PolicyConfig.policyVersion;
  
  void setKvkkAcceptance(bool? value) {
    _acceptKvkk = value ?? false;
    notifyListeners();
  }
  
  void setHealthAcceptance(bool? value) {
    _acceptHealth = value ?? false;
    notifyListeners();
  }
  
  Future<void> openPolicy() async {
    try {
      await launchUrlString(
        PolicyConfig.policyUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Politika açılamadı: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  Future<void> submitConsent() async {
    if (!_acceptKvkk || !_acceptHealth) {
      _snackbarService.showSnackbar(
        message: 'Devam etmek için tüm onayları vermelisiniz.',
        duration: const Duration(seconds: 3),
      );
      return;
    }
    
    setBusy(true);
    try {
      await _consentService.saveConsent(
        kvkkAccepted: _acceptKvkk,
        healthAccepted: _acceptHealth,
      );
      
      _navigationService.back(result: true);
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Onay kaydedilemedi: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }
}
