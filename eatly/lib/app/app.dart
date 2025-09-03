import 'package:eatly/ui/views/login/login_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../ui/views/camera/camera_screen.dart';
import '../ui/views/nutrition/nutrition_view.dart';
import '../ui/views/main/main_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: LoginView, initial: true),
    MaterialRoute(page: MainView),
    MaterialRoute(page: CameraScreen),
    MaterialRoute(page: NutritionView),
  ],
  dependencies: [LazySingleton(classType: NavigationService)],
)
class App {}
