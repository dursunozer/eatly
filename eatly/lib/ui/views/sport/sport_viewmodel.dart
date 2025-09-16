import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';

class SportViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  
  // Spor aktiviteleri listesi
  final List<SportActivity> _activities = [];
  List<SportActivity> get activities => _activities;
  
  // Günlük hedefler
  int _dailyStepGoal = 10000;
  int _currentSteps = 0;
  double _dailyCalorieGoal = 500;
  double _burnedCalories = 0;
  
  int get dailyStepGoal => _dailyStepGoal;
  int get currentSteps => _currentSteps;
  double get dailyCalorieGoal => _dailyCalorieGoal;
  double get burnedCalories => _burnedCalories;
  
  double get stepProgress => _currentSteps / _dailyStepGoal;
  double get calorieProgress => _burnedCalories / _dailyCalorieGoal;
  
  Future<void> initialize() async {
    setBusy(true);
    try {
      // Spor verilerini yükle
      await loadSportData();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Veriler yüklenemedi: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }
  
  Future<void> loadSportData() async {
    // Backend'den veya local storage'dan spor verilerini yükle
    await Future.delayed(const Duration(seconds: 1)); // Simülasyon
    
    _currentSteps = 7500;
    _burnedCalories = 350;
    
    _activities.addAll([
      SportActivity(
        name: 'Koşu',
        duration: 30,
        calories: 250,
        date: DateTime.now(),
      ),
      SportActivity(
        name: 'Yürüyüş',
        duration: 45,
        calories: 100,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
    
    notifyListeners();
  }
  
  void addActivity(SportActivity activity) {
    _activities.insert(0, activity);
    _burnedCalories += activity.calories;
    notifyListeners();
    
    _snackbarService.showSnackbar(
      message: 'Aktivite eklendi!',
      duration: const Duration(seconds: 2),
    );
  }
  
  void updateStepGoal(int newGoal) {
    _dailyStepGoal = newGoal;
    notifyListeners();
  }
  
  void updateCalorieGoal(double newGoal) {
    _dailyCalorieGoal = newGoal;
    notifyListeners();
  }
  
  void updateCurrentSteps(int steps) {
    _currentSteps = steps;
    notifyListeners();
  }
}

class SportActivity {
  final String name;
  final int duration; // dakika
  final double calories;
  final DateTime date;
  
  SportActivity({
    required this.name,
    required this.duration,
    required this.calories,
    required this.date,
  });
}
