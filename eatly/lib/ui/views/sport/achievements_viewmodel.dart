import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/services/sport_service.dart';

class AchievementsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  List<Achievement> _allAchievements = [];
  List<Achievement> get allAchievements => _allAchievements;

  List<UserAchievement> _userAchievements = [];
  List<UserAchievement> get userAchievements => _userAchievements;

  String _selectedCategory = 'all';
  String get selectedCategory => _selectedCategory;

  int get earnedCount => _userAchievements.length;
  int get totalCount => _allAchievements.length;

  double get progressPercentage {
    if (_allAchievements.isEmpty) return 0;
    return _userAchievements.length / _allAchievements.length;
  }

  List<Achievement> get filteredAchievements {
    if (_selectedCategory == 'all') return _allAchievements;
    return _allAchievements.where((a) => a.category == _selectedCategory).toList();
  }

  Future<void> initialize() async {
    setBusy(true);
    try {
      _allAchievements = await SportService.getAllAchievements();
      _userAchievements = await SportService.getUserAchievements();
    } catch (e) {
      print('Achievements load error: $e');
    } finally {
      setBusy(false);
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  bool isAchievementEarned(String achievementId) {
    return _userAchievements.any((ua) => ua.achievementId == achievementId);
  }

  DateTime? getEarnedDate(String achievementId) {
    final userAchievement = _userAchievements
        .where((ua) => ua.achievementId == achievementId)
        .firstOrNull;
    return userAchievement?.earnedAt;
  }

  void navigateBack() {
    _navigationService.back();
  }
}

