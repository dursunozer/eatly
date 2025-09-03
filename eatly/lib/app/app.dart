import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../ui/views/camera/camera_screen.dart';
import '../screens/nutrition_details_screen.dart';
import '../ui/views/main/main_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: MainView, initial: true),
    MaterialRoute(page: CameraScreen),
    MaterialRoute(page: NutritionDetailsScreen),
  ],
  dependencies: [LazySingleton(classType: NavigationService)],
)
class App {}
