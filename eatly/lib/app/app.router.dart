// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:eatly/ui/views/camera/camera_view.dart' as _i11;
import 'package:eatly/ui/views/home/home_view.dart' as _i10;
import 'package:eatly/ui/views/login/consent_update_view.dart' as _i7;
import 'package:eatly/ui/views/login/forgot_password_view.dart' as _i6;
import 'package:eatly/ui/views/login/login_view.dart' as _i4;
import 'package:eatly/ui/views/login/signup_view.dart' as _i5;
import 'package:eatly/ui/views/main/main_view.dart' as _i9;
import 'package:eatly/ui/views/nutrition/nutrition_view.dart' as _i12;
import 'package:eatly/ui/views/onboarding/onboarding_view.dart' as _i8;
import 'package:eatly/ui/views/profile/profile_view.dart' as _i13;
import 'package:eatly/ui/views/sport/achievements_view.dart' as _i18;
import 'package:eatly/ui/views/sport/sport_stats_view.dart' as _i17;
import 'package:eatly/ui/views/sport/sport_view.dart' as _i14;
import 'package:eatly/ui/views/sport/workout_programs_view.dart' as _i16;
import 'package:eatly/ui/views/sport/workout_timer_view.dart' as _i15;
import 'package:eatly/ui/views/startup/startup_view.dart' as _i2;
import 'package:eatly/ui/views/suggestion/suggestion_view.dart' as _i19;
import 'package:eatly/ui/views/welcome/welcome_view.dart' as _i3;
import 'package:flutter/material.dart' as _i20;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i21;

class Routes {
  static const startupView = '/';

  static const welcomeView = '/welcome-view';

  static const loginView = '/login-view';

  static const signupView = '/signup-view';

  static const forgotPasswordView = '/forgot-password-view';

  static const consentUpdateView = '/consent-update-view';

  static const onboardingView = '/onboarding-view';

  static const mainView = '/main-view';

  static const homeView = '/home-view';

  static const cameraView = '/camera-view';

  static const nutritionView = '/nutrition-view';

  static const profileView = '/profile-view';

  static const sportView = '/sport-view';

  static const workoutTimerView = '/workout-timer-view';

  static const workoutProgramsView = '/workout-programs-view';

  static const sportStatsView = '/sport-stats-view';

  static const achievementsView = '/achievements-view';

  static const suggestionView = '/suggestion-view';

  static const all = <String>{
    startupView,
    welcomeView,
    loginView,
    signupView,
    forgotPasswordView,
    consentUpdateView,
    onboardingView,
    mainView,
    homeView,
    cameraView,
    nutritionView,
    profileView,
    sportView,
    workoutTimerView,
    workoutProgramsView,
    sportStatsView,
    achievementsView,
    suggestionView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(Routes.startupView, page: _i2.StartupView),
    _i1.RouteDef(Routes.welcomeView, page: _i3.WelcomeView),
    _i1.RouteDef(Routes.loginView, page: _i4.LoginView),
    _i1.RouteDef(Routes.signupView, page: _i5.SignupView),
    _i1.RouteDef(Routes.forgotPasswordView, page: _i6.ForgotPasswordView),
    _i1.RouteDef(Routes.consentUpdateView, page: _i7.ConsentUpdateView),
    _i1.RouteDef(Routes.onboardingView, page: _i8.OnboardingView),
    _i1.RouteDef(Routes.mainView, page: _i9.MainView),
    _i1.RouteDef(Routes.homeView, page: _i10.HomeView),
    _i1.RouteDef(Routes.cameraView, page: _i11.CameraView),
    _i1.RouteDef(Routes.nutritionView, page: _i12.NutritionView),
    _i1.RouteDef(Routes.profileView, page: _i13.ProfileView),
    _i1.RouteDef(Routes.sportView, page: _i14.SportView),
    _i1.RouteDef(Routes.workoutTimerView, page: _i15.WorkoutTimerView),
    _i1.RouteDef(Routes.workoutProgramsView, page: _i16.WorkoutProgramsView),
    _i1.RouteDef(Routes.sportStatsView, page: _i17.SportStatsView),
    _i1.RouteDef(Routes.achievementsView, page: _i18.AchievementsView),
    _i1.RouteDef(Routes.suggestionView, page: _i19.SuggestionView),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      final args = data.getArgs<StartupViewArguments>(
        orElse: () => const StartupViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i2.StartupView(key: args.key),
        settings: data,
      );
    },
    _i3.WelcomeView: (data) {
      final args = data.getArgs<WelcomeViewArguments>(
        orElse: () => const WelcomeViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i3.WelcomeView(key: args.key),
        settings: data,
      );
    },
    _i4.LoginView: (data) {
      final args = data.getArgs<LoginViewArguments>(
        orElse: () => const LoginViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i4.LoginView(key: args.key),
        settings: data,
      );
    },
    _i5.SignupView: (data) {
      final args = data.getArgs<SignupViewArguments>(
        orElse: () => const SignupViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.SignupView(key: args.key),
        settings: data,
      );
    },
    _i6.ForgotPasswordView: (data) {
      final args = data.getArgs<ForgotPasswordViewArguments>(
        orElse: () => const ForgotPasswordViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i6.ForgotPasswordView(key: args.key),
        settings: data,
      );
    },
    _i7.ConsentUpdateView: (data) {
      final args = data.getArgs<ConsentUpdateViewArguments>(
        orElse: () => const ConsentUpdateViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.ConsentUpdateView(key: args.key),
        settings: data,
      );
    },
    _i8.OnboardingView: (data) {
      final args = data.getArgs<OnboardingViewArguments>(
        orElse: () => const OnboardingViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.OnboardingView(key: args.key),
        settings: data,
      );
    },
    _i9.MainView: (data) {
      final args = data.getArgs<MainViewArguments>(
        orElse: () => const MainViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i9.MainView(key: args.key),
        settings: data,
      );
    },
    _i10.HomeView: (data) {
      final args = data.getArgs<HomeViewArguments>(
        orElse: () => const HomeViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i10.HomeView(key: args.key),
        settings: data,
      );
    },
    _i11.CameraView: (data) {
      final args = data.getArgs<CameraViewArguments>(
        orElse: () => const CameraViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i11.CameraView(key: args.key),
        settings: data,
      );
    },
    _i12.NutritionView: (data) {
      final args = data.getArgs<NutritionViewArguments>(
        orElse: () => const NutritionViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i12.NutritionView(key: args.key),
        settings: data,
      );
    },
    _i13.ProfileView: (data) {
      final args = data.getArgs<ProfileViewArguments>(
        orElse: () => const ProfileViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i13.ProfileView(key: args.key),
        settings: data,
      );
    },
    _i14.SportView: (data) {
      final args = data.getArgs<SportViewArguments>(
        orElse: () => const SportViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i14.SportView(key: args.key),
        settings: data,
      );
    },
    _i15.WorkoutTimerView: (data) {
      final args = data.getArgs<WorkoutTimerViewArguments>(
        orElse: () => const WorkoutTimerViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i15.WorkoutTimerView(key: args.key),
        settings: data,
      );
    },
    _i16.WorkoutProgramsView: (data) {
      final args = data.getArgs<WorkoutProgramsViewArguments>(
        orElse: () => const WorkoutProgramsViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i16.WorkoutProgramsView(key: args.key),
        settings: data,
      );
    },
    _i17.SportStatsView: (data) {
      final args = data.getArgs<SportStatsViewArguments>(
        orElse: () => const SportStatsViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i17.SportStatsView(key: args.key),
        settings: data,
      );
    },
    _i18.AchievementsView: (data) {
      final args = data.getArgs<AchievementsViewArguments>(
        orElse: () => const AchievementsViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i18.AchievementsView(key: args.key),
        settings: data,
      );
    },
    _i19.SuggestionView: (data) {
      final args = data.getArgs<SuggestionViewArguments>(
        orElse: () => const SuggestionViewArguments(),
      );
      return _i20.MaterialPageRoute<dynamic>(
        builder: (context) => _i19.SuggestionView(key: args.key),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class StartupViewArguments {
  const StartupViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant StartupViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class WelcomeViewArguments {
  const WelcomeViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant WelcomeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LoginViewArguments {
  const LoginViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SignupViewArguments {
  const SignupViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SignupViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class ForgotPasswordViewArguments {
  const ForgotPasswordViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ForgotPasswordViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class ConsentUpdateViewArguments {
  const ConsentUpdateViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ConsentUpdateViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class OnboardingViewArguments {
  const OnboardingViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant OnboardingViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class MainViewArguments {
  const MainViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant MainViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class HomeViewArguments {
  const HomeViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant HomeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class CameraViewArguments {
  const CameraViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant CameraViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class NutritionViewArguments {
  const NutritionViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant NutritionViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class ProfileViewArguments {
  const ProfileViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ProfileViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SportViewArguments {
  const SportViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SportViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class WorkoutTimerViewArguments {
  const WorkoutTimerViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant WorkoutTimerViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class WorkoutProgramsViewArguments {
  const WorkoutProgramsViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant WorkoutProgramsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SportStatsViewArguments {
  const SportStatsViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SportStatsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AchievementsViewArguments {
  const AchievementsViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AchievementsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SuggestionViewArguments {
  const SuggestionViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SuggestionViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

extension NavigatorStateExtension on _i21.NavigationService {
  Future<dynamic> navigateToStartupView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.startupView,
      arguments: StartupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToWelcomeView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.welcomeView,
      arguments: WelcomeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToLoginView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.loginView,
      arguments: LoginViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSignupView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.signupView,
      arguments: SignupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToForgotPasswordView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.forgotPasswordView,
      arguments: ForgotPasswordViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToConsentUpdateView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.consentUpdateView,
      arguments: ConsentUpdateViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToOnboardingView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.onboardingView,
      arguments: OnboardingViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToMainView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.mainView,
      arguments: MainViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToHomeView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.homeView,
      arguments: HomeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToCameraView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.cameraView,
      arguments: CameraViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToNutritionView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.nutritionView,
      arguments: NutritionViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToProfileView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.profileView,
      arguments: ProfileViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSportView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.sportView,
      arguments: SportViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToWorkoutTimerView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.workoutTimerView,
      arguments: WorkoutTimerViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToWorkoutProgramsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.workoutProgramsView,
      arguments: WorkoutProgramsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSportStatsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.sportStatsView,
      arguments: SportStatsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToAchievementsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.achievementsView,
      arguments: AchievementsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSuggestionView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.suggestionView,
      arguments: SuggestionViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithStartupView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.startupView,
      arguments: StartupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithWelcomeView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.welcomeView,
      arguments: WelcomeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithLoginView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.loginView,
      arguments: LoginViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSignupView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.signupView,
      arguments: SignupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithForgotPasswordView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.forgotPasswordView,
      arguments: ForgotPasswordViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithConsentUpdateView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.consentUpdateView,
      arguments: ConsentUpdateViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithOnboardingView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.onboardingView,
      arguments: OnboardingViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithMainView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.mainView,
      arguments: MainViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithHomeView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.homeView,
      arguments: HomeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithCameraView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.cameraView,
      arguments: CameraViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithNutritionView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.nutritionView,
      arguments: NutritionViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithProfileView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.profileView,
      arguments: ProfileViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSportView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.sportView,
      arguments: SportViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithWorkoutTimerView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.workoutTimerView,
      arguments: WorkoutTimerViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithWorkoutProgramsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.workoutProgramsView,
      arguments: WorkoutProgramsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSportStatsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.sportStatsView,
      arguments: SportStatsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithAchievementsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.achievementsView,
      arguments: AchievementsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSuggestionView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.suggestionView,
      arguments: SuggestionViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }
}
