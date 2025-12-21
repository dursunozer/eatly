import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/services/sport_service.dart';
import '../../../core/services/health_service.dart';

class SportViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _healthService = HealthService();

  // Günlük özet
  DailySportSummary? _dailySummary;
  DailySportSummary? get dailySummary => _dailySummary;

  // Aktiviteler
  List<SportActivityData> _activities = [];
  List<SportActivityData> get activities => _activities;

  // Haftalık veriler
  List<DailyStepData> _weeklySteps = [];
  List<DailyStepData> get weeklySteps => _weeklySteps;

  List<DailyWaterData> _weeklyWater = [];
  List<DailyWaterData> get weeklyWater => _weeklyWater;

  // Antrenman programları
  List<WorkoutProgram> _programs = [];
  List<WorkoutProgram> get programs => _programs;

  // Rozetler
  List<Achievement> _allAchievements = [];
  List<Achievement> get allAchievements => _allAchievements;

  List<UserAchievement> _userAchievements = [];
  List<UserAchievement> get userAchievements => _userAchievements;

  // Health Connect durumu
  bool _isHealthConnected = false;
  bool get isHealthConnected => _isHealthConnected;

  // Aktif sekme
  int _activeTab = 0;
  int get activeTab => _activeTab;

  // Getter'lar
  int get currentSteps => _dailySummary?.steps ?? 0;
  int get dailyStepGoal => _dailySummary?.stepGoal ?? 10000;
  double get stepProgress => _dailySummary?.stepProgress ?? 0;

  double get burnedCalories => _dailySummary?.caloriesBurned ?? 0;
  double get dailyCalorieGoal => _dailySummary?.calorieGoal ?? 500;
  double get calorieProgress => _dailySummary?.calorieProgress ?? 0;

  int get waterIntake => _dailySummary?.waterIntakeMl ?? 0;
  int get waterGoal => _dailySummary?.waterGoalMl ?? 2000;
  double get waterProgress => _dailySummary?.waterProgress ?? 0;

  int get workoutMinutes => _dailySummary?.workoutMinutes ?? 0;
  int get activitiesCount => _dailySummary?.activitiesCount ?? 0;

  int get earnedAchievementsCount => _userAchievements.length;
  int get totalAchievementsCount => _allAchievements.length;

  Future<void> initialize() async {
    setBusy(true);
    try {
      await Future.wait([
        loadDailySummary(),
        loadActivities(),
        loadWeeklyData(),
        loadPrograms(),
        loadAchievements(),
        checkHealthConnectStatus(),
      ]);
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Veriler yüklenemedi: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadDailySummary() async {
    try {
      _dailySummary = await SportService.getDailySummary();
      notifyListeners();
    } catch (e) {
      print('Daily summary error: $e');
    }
  }

  Future<void> loadActivities() async {
    try {
      _activities = await SportService.getActivities(limit: 20);
      notifyListeners();
    } catch (e) {
      print('Activities error: $e');
    }
  }

  Future<void> loadWeeklyData() async {
    try {
      _weeklySteps = await SportService.getWeeklyStepData();
      _weeklyWater = await SportService.getWeeklyWaterData();
      notifyListeners();
    } catch (e) {
      print('Weekly data error: $e');
    }
  }

  Future<void> loadPrograms() async {
    try {
      _programs = await SportService.getWorkoutPrograms();
      notifyListeners();
    } catch (e) {
      print('Programs error: $e');
    }
  }

  Future<void> loadAchievements() async {
    try {
      _allAchievements = await SportService.getAllAchievements();
      _userAchievements = await SportService.getUserAchievements();
      notifyListeners();
    } catch (e) {
      print('Achievements error: $e');
    }
  }

  Future<void> checkHealthConnectStatus() async {
    try {
      _isHealthConnected = await _healthService.isHealthAvailable() &&
          _healthService.isAuthorized;
      notifyListeners();
    } catch (e) {
      _isHealthConnected = false;
    }
  }

  Future<void> connectHealthConnect() async {
    setBusy(true);
    try {
      // Önce Health Connect'in kurulu olup olmadığını kontrol et
      final available = await _healthService.isHealthAvailable();
      
      if (!available) {
        // Health Connect kurulu değil, Play Store'a yönlendir
        try {
          await _healthService.installHealthConnect();
          _snackbarService.showSnackbar(
            message: 'Health Connect Play Store\'da açılıyor...',
            duration: const Duration(seconds: 3),
          );
        } catch (e) {
          _snackbarService.showSnackbar(
            message: 'Health Connect kurulu değil. Lütfen Play Store\'dan yükleyin.',
            duration: const Duration(seconds: 4),
          );
        }
        return;
      }

      // İzin iste
      final authorized = await _healthService.requestAuthorization();
      
      if (authorized) {
        _isHealthConnected = true;
        notifyListeners();
        await loadDailySummary();
        _snackbarService.showSnackbar(
          message: 'Health Connect bağlandı! Veriler senkronize ediliyor...',
          duration: const Duration(seconds: 2),
        );
      } else {
        _snackbarService.showSnackbar(
          message: 'İzin verilmedi. Lütfen Health Connect uygulamasından izinleri kontrol edin.',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      debugPrint('Health Connect bağlantı hatası: $e');
      _snackbarService.showSnackbar(
        message: 'Bağlantı hatası: ${e.toString().length > 50 ? e.toString().substring(0, 50) + "..." : e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  void setActiveTab(int index) {
    _activeTab = index;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await Future.wait([
      loadDailySummary(),
      loadActivities(),
      loadWeeklyData(),
    ]);

    // Rozet kontrolü
    final newAchievements = await SportService.checkAndAwardAchievements();
    if (newAchievements.isNotEmpty) {
      await loadAchievements();
      for (final achievement in newAchievements) {
        _snackbarService.showSnackbar(
          message: '🏆 Yeni rozet: ${achievement.nameTr}',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  // Su ekleme
  Future<void> addWater(int amountMl) async {
    try {
      await SportService.addWaterIntake(amountMl);
      await loadDailySummary();
      _snackbarService.showSnackbar(
        message: '$amountMl ml su eklendi',
        duration: const Duration(seconds: 2),
      );

      // Rozet kontrolü
      await SportService.checkAndAwardAchievements();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Su eklenirken hata: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Hızlı aktivite ekleme
  Future<void> addQuickActivity(String name, String type, int duration, double calories) async {
    try {
      await SportService.addActivity(
        name: name,
        activityType: type,
        durationMinutes: duration,
        caloriesBurned: calories,
      );
      await Future.wait([
        loadDailySummary(),
        loadActivities(),
      ]);
      _snackbarService.showSnackbar(
        message: '$name eklendi!',
        duration: const Duration(seconds: 2),
      );

      // Rozet kontrolü
      final newAchievements = await SportService.checkAndAwardAchievements();
      if (newAchievements.isNotEmpty) {
        await loadAchievements();
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Aktivite eklenirken hata: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Aktivite silme
  Future<void> deleteActivity(String activityId) async {
    try {
      await SportService.deleteActivity(activityId);
      await Future.wait([
        loadDailySummary(),
        loadActivities(),
      ]);
      _snackbarService.showSnackbar(
        message: 'Aktivite silindi',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Silme hatası: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Navigasyon metodları
  void navigateToWorkoutTimer() {
    _navigationService.navigateTo(Routes.workoutTimerView);
  }

  void navigateToWorkoutPrograms() {
    _navigationService.navigateTo(Routes.workoutProgramsView);
  }

  void navigateToSportStats() {
    _navigationService.navigateTo(Routes.sportStatsView);
  }

  void navigateToAchievements() {
    _navigationService.navigateTo(Routes.achievementsView);
  }

  // Hedef güncelleme
  Future<void> updateStepGoal(int newGoal) async {
    try {
      await SportService.updateSportGoals(dailyStepGoal: newGoal);
      await loadDailySummary();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Hedef güncellenemedi: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> updateCalorieGoal(double newGoal) async {
    try {
      await SportService.updateSportGoals(dailyCalorieBurnGoal: newGoal);
      await loadDailySummary();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Hedef güncellenemedi: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> updateWaterGoal(int newGoal) async {
    try {
      await SportService.updateWaterGoal(newGoal);
      await loadDailySummary();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Hedef güncellenemedi: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }
}
