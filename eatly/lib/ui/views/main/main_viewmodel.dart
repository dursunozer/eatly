import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../camera/camera_screen.dart';

class MainViewModel extends BaseViewModel {
  final _nav = locator<NavigationService>();

  int currentIndex = 0;
  int refreshTick = 0; // HomeView'i zorla yeniden oluşturmak için artan sayaç

  void onTabSelected(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future<void> goToCamera() async {
    final result = await _nav.navigateToView(const CameraScreen());
    // Kamera sayfasından true dönerse ana sayfayı yenilemek için notifyListeners
    if (result == true) {
      refreshTick++;
      notifyListeners();
    }
  }
}
