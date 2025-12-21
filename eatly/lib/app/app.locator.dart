// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_services/src/snackbar/snackbar_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/consent_service.dart';
import '../core/services/huggingface_service.dart';
import '../core/services/meal_service.dart';
import '../core/services/nutrition_service.dart';
import '../core/services/photo_service.dart';
import '../core/services/supabase_service.dart';
import '../core/services/user_service.dart';
import '../core/services/vision_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
  // Register environments
  locator.registerEnvironment(
    environment: environment,
    environmentFilter: environmentFilter,
  );

  // Register dependencies
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => VisionService());
  locator.registerLazySingleton(() => PhotoService());
  locator.registerLazySingleton(() => ConsentService());
  locator.registerLazySingleton(() => SupabaseService());
  locator.registerLazySingleton(() => NutritionService());
  locator.registerLazySingleton(() => MealService());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => HuggingFaceService());
}
