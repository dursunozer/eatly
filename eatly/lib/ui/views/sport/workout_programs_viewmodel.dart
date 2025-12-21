import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/services/sport_service.dart';

class WorkoutProgramsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  List<WorkoutProgram> _programs = [];
  List<WorkoutProgram> get programs => _programs;

  String _selectedCategory = 'all';
  String get selectedCategory => _selectedCategory;

  WorkoutProgram? _selectedProgram;
  WorkoutProgram? get selectedProgram => _selectedProgram;

  int _selectedWeek = 1;
  int get selectedWeek => _selectedWeek;

  List<WorkoutExercise> _weekExercises = [];
  List<WorkoutExercise> get weekExercises => _weekExercises;

  final Map<String, int> _programProgress = {};

  List<WorkoutProgram> get filteredPrograms {
    if (_selectedCategory == 'all') return _programs;
    return _programs.where((p) => p.category == _selectedCategory).toList();
  }

  Future<void> initialize() async {
    setBusy(true);
    try {
      _programs = await SportService.getWorkoutPrograms();

      // Her programın ilerlemesini yükle
      for (final program in _programs) {
        _programProgress[program.id] = await SportService.getProgramProgress(program.id);
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Programlar yüklenemedi: $e',
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> selectProgram(WorkoutProgram program) async {
    _selectedProgram = program;
    _selectedWeek = 1;
    await _loadWeekExercises();
    notifyListeners();
  }

  void clearSelection() {
    _selectedProgram = null;
    _weekExercises = [];
    notifyListeners();
  }

  Future<void> selectWeek(int week) async {
    _selectedWeek = week;
    await _loadWeekExercises();
    notifyListeners();
  }

  Future<void> _loadWeekExercises() async {
    if (_selectedProgram == null) return;

    try {
      _weekExercises = await SportService.getProgramExercises(
        _selectedProgram!.id,
        week: _selectedWeek,
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Egzersizler yüklenemedi: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  int getProgramProgress(String programId) {
    return _programProgress[programId] ?? 0;
  }

  void startExercise(WorkoutExercise exercise) {
    // Workout timer sayfasına yönlendir
    _navigationService.navigateTo(Routes.workoutTimerView);
  }

  void navigateBack() {
    if (_selectedProgram != null) {
      clearSelection();
    } else {
      _navigationService.back();
    }
  }
}

