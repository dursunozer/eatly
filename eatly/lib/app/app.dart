import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// Views
import '../ui/views/login/login_view.dart';
import '../ui/views/login/signup_view.dart';
import '../ui/views/login/forgot_password_view.dart';
import '../ui/views/login/consent_update_view.dart';
import '../ui/views/main/main_view.dart';
import '../ui/views/home/home_view.dart';
import '../ui/views/camera/camera_view.dart';
import '../ui/views/nutrition/nutrition_view.dart';
import '../ui/views/profile/profile_view.dart';
import '../ui/views/sport/sport_view.dart';
import '../ui/views/sport/workout_timer_view.dart';
import '../ui/views/sport/workout_programs_view.dart';
import '../ui/views/sport/sport_stats_view.dart';
import '../ui/views/sport/achievements_view.dart';
import '../ui/views/suggestion/suggestion_view.dart';
import '../ui/views/startup/startup_view.dart';
import '../ui/views/onboarding/onboarding_view.dart';
import '../ui/views/welcome/welcome_view.dart';

// Bottom Sheets
import '../ui/bottom_sheets/notice/notice_sheet.dart';
import '../ui/bottom_sheets/analysis_results/analysis_results_sheet.dart';

// Dialogs
import '../ui/dialogs/info_alert/info_alert_dialog.dart';

// Services
import '../core/services/auth_service.dart';
import '../core/services/user_service.dart';
import '../core/services/vision_service.dart';
import '../core/services/photo_service.dart';
import '../core/services/consent_service.dart';
import '../core/services/powersync_service.dart';
import '../core/services/supabase_service.dart';
import '../core/services/nutrition_service.dart';
import '../core/services/meal_service.dart';
import '../core/services/api_service.dart';
import '../core/services/huggingface_service.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: WelcomeView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: SignupView),
    MaterialRoute(page: ForgotPasswordView),
    MaterialRoute(page: ConsentUpdateView),
    MaterialRoute(page: OnboardingView),
    MaterialRoute(page: MainView),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: CameraView),
    MaterialRoute(page: NutritionView),
    MaterialRoute(page: ProfileView),
    MaterialRoute(page: SportView),
    MaterialRoute(page: WorkoutTimerView),
    MaterialRoute(page: WorkoutProgramsView),
    MaterialRoute(page: SportStatsView),
    MaterialRoute(page: AchievementsView),
    MaterialRoute(page: SuggestionView),
  ],
  dependencies: [
    // Stacked Services
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: SnackbarService),
    
    // App Services
    LazySingleton(classType: AuthService),
    LazySingleton(classType: UserService),
    LazySingleton(classType: VisionService),
    LazySingleton(classType: PhotoService),
    LazySingleton(classType: ConsentService),
    LazySingleton(classType: SupabaseService),
    LazySingleton(classType: NutritionService),
    LazySingleton(classType: MealService),
    LazySingleton(classType: ApiService),
    LazySingleton(classType: HuggingFaceService),
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    StackedBottomsheet(classType: AnalysisResultsSheet),
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
  ],
  logger: StackedLogger(),
)
class App {}

// Bottom Sheet Types
enum BottomSheetType {
  notice,
  analysisResults,
}