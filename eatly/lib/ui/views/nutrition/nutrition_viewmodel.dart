import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../core/models/daily_summary.dart';
import '../../../core/services/history_service.dart';

class NutritionViewModel extends BaseViewModel {
  final HistoryService _historyService = HistoryService();
  
  DateTime _selectedDate = DateTime.now();
  DailySummary? _dailySummary;
  bool _isLoading = false;
  String? _errorMessage;

  DateTime get selectedDate => _selectedDate;
  DailySummary? get dailySummary => _dailySummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get formattedSelectedDate => DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate);
  String get formattedSelectedDateShort => DateFormat('dd MMM', 'tr_TR').format(_selectedDate);

  Future<void> init() async {
    await loadDataForDate(_selectedDate);
    
    // Bugünkü veriler için periyodik güncelleme
    if (isToday) {
      _startPeriodicRefresh();
    }
  }

  Timer? _refreshTimer;

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isToday) {
        loadDataForDate(_selectedDate);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadDataForDate(DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedDate = date;
      _dailySummary = await _historyService.getDailySummaryForDate(date);
      
      // Bugünkü veriler için periyodik güncelleme başlat
      if (isToday) {
        _startPeriodicRefresh();
      } else {
        _refreshTimer?.cancel();
      }
    } catch (e) {
      _errorMessage = 'Veri yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPreviousDay() async {
    final previousDay = _selectedDate.subtract(const Duration(days: 1));
    await loadDataForDate(previousDay);
  }

  Future<void> selectNextDay() async {
    final nextDay = _selectedDate.add(const Duration(days: 1));
    // Gelecek tarih seçimini engelle
    if (nextDay.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      await loadDataForDate(nextDay);
    }
  }

  bool get canGoToNextDay {
    final nextDay = _selectedDate.add(const Duration(days: 1));
    return nextDay.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  bool get canGoToPreviousDay {
    // Son 30 günü göster
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _selectedDate.isAfter(thirtyDaysAgo);
  }

  Future<void> selectToday() async {
    await loadDataForDate(DateTime.now());
  }

  bool get isToday {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
           _selectedDate.month == today.month &&
           _selectedDate.day == today.day;
  }
}
