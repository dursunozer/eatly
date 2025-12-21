import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/services/sport_service.dart';

class WorkoutTimerViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  Timer? _timer;
  int _elapsedSeconds = 0;
  int _restSeconds = 0;
  int _totalElapsedSeconds = 0;

  // Egzersiz ayarları
  String _currentExercise = 'Squat';
  String _currentExerciseDescription = 'Sırtını düz tut, dizleri 90 dereceye kadar bük';
  IconData _currentExerciseIcon = Icons.fitness_center;

  int _totalSets = 3;
  int _totalReps = 10;
  int _currentSet = 1;
  int _currentRep = 0;
  int _restDuration = 60; // saniye
  double _caloriesPerRep = 0.5;
  double _caloriesBurned = 0;

  bool _hasStarted = false;
  bool _isTimerRunning = false;
  bool _isResting = false;
  bool _isWorkoutComplete = false;

  // Getters
  String get currentExercise => _currentExercise;
  String get currentExerciseDescription => _currentExerciseDescription;
  IconData get currentExerciseIcon => _currentExerciseIcon;

  int get totalSets => _totalSets;
  int get totalReps => _totalReps;
  int get currentSet => _currentSet;
  int get currentRep => _currentRep;
  int get caloriesBurned => _caloriesBurned.toInt();

  bool get hasStarted => _hasStarted;
  bool get isTimerRunning => _isTimerRunning;
  bool get isResting => _isResting;
  bool get isWorkoutComplete => _isWorkoutComplete;

  double get progress {
    if (_isResting) {
      return _restSeconds > 0 ? (_restDuration - _restSeconds) / _restDuration : 0;
    }
    return _totalReps > 0 ? _currentRep / _totalReps : 0;
  }

  String get timerDisplay {
    if (_isResting) {
      final minutes = _restSeconds ~/ 60;
      final seconds = _restSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get totalTimeDisplay {
    final minutes = _totalElapsedSeconds ~/ 60;
    final seconds = _totalElapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> get exerciseList => [
        {
          'name': 'Squat',
          'description': 'Sırtını düz tut, dizleri 90 dereceye kadar bük',
          'icon': Icons.fitness_center,
          'caloriesPerRep': 0.5,
        },
        {
          'name': 'Push-up',
          'description': 'Vücudunu düz tut, göğsünü yere yaklaştır',
          'icon': Icons.sports_gymnastics,
          'caloriesPerRep': 0.4,
        },
        {
          'name': 'Plank',
          'description': 'Vücudunu düz çizgide tut',
          'icon': Icons.straighten,
          'caloriesPerRep': 0.3,
        },
        {
          'name': 'Lunge',
          'description': 'Bir adım öne at, dizleri 90 derece bük',
          'icon': Icons.directions_walk,
          'caloriesPerRep': 0.5,
        },
        {
          'name': 'Burpee',
          'description': 'Tam vücut patlayıcı hareket',
          'icon': Icons.flash_on,
          'caloriesPerRep': 1.0,
        },
        {
          'name': 'Mountain Climber',
          'description': 'Plank pozisyonunda hızlı diz çekme',
          'icon': Icons.terrain,
          'caloriesPerRep': 0.6,
        },
        {
          'name': 'Jumping Jack',
          'description': 'Kolları ve bacakları açarak zıplama',
          'icon': Icons.accessibility_new,
          'caloriesPerRep': 0.4,
        },
        {
          'name': 'Crunch',
          'description': 'Karın kaslarını sıkarak kalkma',
          'icon': Icons.self_improvement,
          'caloriesPerRep': 0.3,
        },
      ];

  void selectExercise(Map<String, dynamic> exercise) {
    _currentExercise = exercise['name'] as String;
    _currentExerciseDescription = exercise['description'] as String;
    _currentExerciseIcon = exercise['icon'] as IconData;
    _caloriesPerRep = exercise['caloriesPerRep'] as double;
    notifyListeners();
  }

  void adjustSets(int delta) {
    _totalSets = (_totalSets + delta).clamp(1, 20);
    notifyListeners();
  }

  void adjustReps(int delta) {
    _totalReps = (_totalReps + delta).clamp(1, 50);
    notifyListeners();
  }

  void startTimer() {
    _hasStarted = true;
    _isTimerRunning = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isResting) {
        if (_restSeconds > 0) {
          _restSeconds--;
          _totalElapsedSeconds++;
        } else {
          _endRest();
        }
      } else {
        _elapsedSeconds++;
        _totalElapsedSeconds++;
      }
      notifyListeners();
    });

    notifyListeners();
  }

  void pauseTimer() {
    _isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void nextRep() {
    if (_currentRep < _totalReps) {
      _currentRep++;
      _caloriesBurned += _caloriesPerRep;

      if (_currentRep >= _totalReps) {
        // Set tamamlandı
        if (_currentSet < _totalSets) {
          // Otomatik dinlenme başlat
          startRest(_restDuration);
        } else {
          // Antrenman tamamlandı
          _completeWorkout();
        }
      }
    }
    notifyListeners();
  }

  void previousRep() {
    if (_currentRep > 0) {
      _currentRep--;
      _caloriesBurned = (_caloriesBurned - _caloriesPerRep).clamp(0, double.infinity);
    }
    notifyListeners();
  }

  void startRest(int seconds) {
    _isResting = true;
    _restDuration = seconds;
    _restSeconds = seconds;

    if (!_isTimerRunning) {
      startTimer();
    }

    notifyListeners();
  }

  void adjustRestTime(int delta) {
    _restSeconds = (_restSeconds + delta).clamp(0, 300);
    notifyListeners();
  }

  void _endRest() {
    _isResting = false;
    _currentSet++;
    _currentRep = 0;
    _elapsedSeconds = 0;

    if (_currentSet > _totalSets) {
      _completeWorkout();
    }

    notifyListeners();
  }

  void _completeWorkout() {
    _isWorkoutComplete = true;
    _isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resetWorkout() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _restSeconds = 0;
    _totalElapsedSeconds = 0;
    _currentSet = 1;
    _currentRep = 0;
    _caloriesBurned = 0;
    _hasStarted = false;
    _isTimerRunning = false;
    _isResting = false;
    _isWorkoutComplete = false;
    notifyListeners();
  }

  Future<void> saveAndExit() async {
    setBusy(true);
    try {
      // Aktiviteyi kaydet
      await SportService.addActivity(
        name: _currentExercise,
        activityType: 'workout',
        durationMinutes: _totalElapsedSeconds ~/ 60,
        caloriesBurned: _caloriesBurned,
        notes: '$_totalSets set × $_totalReps tekrar',
      );

      _snackbarService.showSnackbar(
        message: 'Antrenman kaydedildi!',
        duration: const Duration(seconds: 2),
      );

      // Kısa bir gecikme sonrası geri dön (kullanıcı mesajı görebilsin)
      await Future.delayed(const Duration(milliseconds: 500));
      navigateBack();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Kaydetme hatası: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  void navigateBack() {
    _timer?.cancel();
    _navigationService.back();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

