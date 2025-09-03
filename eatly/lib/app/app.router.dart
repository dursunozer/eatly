// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:eatly/ui/views/camera/camera_screen.dart' as _i3;
import 'package:eatly/screens/nutrition_details_screen.dart' as _i4;
import 'package:eatly/ui/views/main/main_view.dart' as _i2;
import 'package:flutter/material.dart' as _i5;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i6;

class Routes {
  static const mainView = '/';

  static const cameraScreen = '/camera-screen';

  static const nutritionDetailsScreen = '/nutrition-details-screen';

  static const all = <String>{mainView, cameraScreen, nutritionDetailsScreen};
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(Routes.mainView, page: _i2.MainView),
    _i1.RouteDef(Routes.cameraScreen, page: _i3.CameraScreen),
    _i1.RouteDef(
      Routes.nutritionDetailsScreen,
      page: _i4.NutritionDetailsScreen,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.MainView: (data) {
      return _i5.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.MainView(),
        settings: data,
      );
    },
    _i3.CameraScreen: (data) {
      return _i5.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.CameraScreen(),
        settings: data,
      );
    },
    _i4.NutritionDetailsScreen: (data) {
      return _i5.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.NutritionDetailsScreen(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

extension NavigatorStateExtension on _i6.NavigationService {
  Future<dynamic> navigateToMainView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(
      Routes.mainView,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToCameraScreen([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(
      Routes.cameraScreen,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToNutritionDetailsScreen([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(
      Routes.nutritionDetailsScreen,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithMainView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(
      Routes.mainView,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithCameraScreen([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(
      Routes.cameraScreen,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithNutritionDetailsScreen([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(
      Routes.nutritionDetailsScreen,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }
}
