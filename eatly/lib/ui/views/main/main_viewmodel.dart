import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../camera/camera_screen.dart';

class MainViewModel extends BaseViewModel {
  final _nav = locator<NavigationService>();

  int currentIndex = 0;

  void onTabSelected(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future<void> goToCamera() async {
    await _nav.navigateToView(const CameraScreen());
  }
}
