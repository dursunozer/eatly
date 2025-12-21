import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/services/sport_service.dart';
import '../../../core/services/health_service.dart';

class SportStatsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  String _selectedPeriod = 'week';
  String get selectedPeriod => _selectedPeriod;

  List<DailyStepData> _weeklySteps = [];
  List<DailyStepData> get weeklySteps => _weeklySteps;

  List<DailyWaterData> _weeklyWater = [];
  List<DailyWaterData> get weeklyWater => _weeklyWater;

  List<double> _weeklyCalories = [];
  List<double> get weeklyCalories => _weeklyCalories;

  Map<String, int> _activityDistribution = {};
  Map<String, int> get activityDistribution => _activityDistribution;

  int _waterGoal = 2000;
  int get waterGoal => _waterGoal;

  int _totalSteps = 0;
  int get totalSteps => _totalSteps;

  double _totalCalories = 0;
  double get totalCalories => _totalCalories;

  double _stepsTrend = 0;
  double get stepsTrend => _stepsTrend;

  double _caloriesTrend = 0;
  double get caloriesTrend => _caloriesTrend;

  int get maxSteps {
    if (_weeklySteps.isEmpty) return 10000;
    return _weeklySteps.map((e) => e.steps).reduce((a, b) => a > b ? a : b);
  }

  double get maxDailyCalories {
    if (_weeklyCalories.isEmpty) return 500;
    return _weeklyCalories.reduce((a, b) => a > b ? a : b);
  }

  Future<void> initialize() async {
    setBusy(true);
    try {
      await loadData();
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadData() async {
    await Future.wait([
      _loadStepsData(),
      _loadWaterData(),
      _loadCaloriesData(),
      _loadActivityDistribution(),
      _loadWaterGoal(),
    ]);
    _calculateTrends();
    notifyListeners();
  }

  Future<void> _loadStepsData() async {
    _weeklySteps = await SportService.getWeeklyStepData();
    _totalSteps = _weeklySteps.fold(0, (sum, data) => sum + data.steps);
  }

  Future<void> _loadWaterData() async {
    _weeklyWater = await SportService.getWeeklyWaterData();
  }

  Future<void> _loadCaloriesData() async {
    final activities = await SportService.getActivities(limit: 100);
    final now = DateTime.now();

    _weeklyCalories = List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day - (6 - index));
      final dayActivities = activities.where((a) {
        final activityDate = DateTime(
          a.activityDate.year,
          a.activityDate.month,
          a.activityDate.day,
        );
        return activityDate == date;
      });
      return dayActivities.fold(0.0, (sum, a) => sum + a.caloriesBurned);
    });

    _totalCalories = _weeklyCalories.fold(0.0, (sum, c) => sum + c);
  }

  Future<void> _loadActivityDistribution() async {
    final activities = await SportService.getActivities(limit: 100);

    final Map<String, int> counts = {};
    for (final activity in activities) {
      counts[activity.activityType] = (counts[activity.activityType] ?? 0) + 1;
    }

    if (counts.isEmpty) {
      _activityDistribution = {};
      return;
    }

    final total = counts.values.fold(0, (sum, c) => sum + c);
    _activityDistribution = counts.map((key, value) {
      return MapEntry(key, ((value / total) * 100).round());
    });
  }

  Future<void> _loadWaterGoal() async {
    _waterGoal = await SportService.getWaterGoal();
  }

  void _calculateTrends() {
    // Adım trendi (bu hafta vs geçen hafta)
    if (_weeklySteps.length >= 7) {
      final thisWeekSteps = _weeklySteps.take(7).fold(0, (sum, d) => sum + d.steps);
      // Basit bir karşılaştırma (ortalamaya göre)
      final avgSteps = thisWeekSteps / 7;
      final goal = 10000;
      _stepsTrend = ((avgSteps - goal) / goal) * 100;
    }

    // Kalori trendi
    if (_weeklyCalories.length >= 7) {
      final thisWeekCalories = _weeklyCalories.fold(0.0, (sum, c) => sum + c);
      final avgCalories = thisWeekCalories / 7;
      final goal = 500.0;
      _caloriesTrend = ((avgCalories - goal) / goal) * 100;
    }
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    loadData();
  }

  String getDayLabel(int index) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day - (6 - index));
    final weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return weekdays[date.weekday - 1];
  }

  void navigateBack() {
    _navigationService.back();
  }
}

