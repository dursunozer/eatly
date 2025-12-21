import 'dart:io';
import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

/// Health Connect (Android) ve HealthKit (iOS) entegrasyonu için servis
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();
  bool _isAuthorized = false;

  /// İzin istenen veri tipleri
  static final List<HealthDataType> _dataTypesAndroid = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    // SLEEP_IN_BED Android Health Connect'te desteklenmiyor
    HealthDataType.WORKOUT,
  ];

  static final List<HealthDataType> _dataTypesIOS = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.WORKOUT,
  ];

  List<HealthDataType> get _dataTypes =>
      Platform.isAndroid ? _dataTypesAndroid : _dataTypesIOS;

  /// İzin durumunu kontrol et
  bool get isAuthorized => _isAuthorized;

  /// Health Connect/HealthKit kurulu mu kontrol et
  Future<bool> isHealthAvailable() async {
    try {
      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        return status == HealthConnectSdkStatus.sdkAvailable;
      }
      return true; // iOS için HealthKit her zaman mevcut
    } catch (e) {
      debugPrint('Health availability check error: $e');
      return false;
    }
  }

  /// Health Connect kurulumu için yönlendir (sadece Android)
  Future<void> installHealthConnect() async {
    if (Platform.isAndroid) {
      await _health.installHealthConnect();
    }
  }

  /// Sağlık verilerine erişim izni iste
  Future<bool> requestAuthorization() async {
    try {
      // Platform bazlı veri tiplerini al
      final dataTypes = _dataTypes;
      
      // Android'de Health Connect kurulu mu kontrol et
      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        if (status != HealthConnectSdkStatus.sdkAvailable) {
          debugPrint('Health Connect SDK mevcut değil. Durum: $status');
          return false;
        }
      }
      
      // Önce mevcut izinleri kontrol et
      final hasPermissions = await _health.hasPermissions(
        dataTypes,
        permissions: dataTypes.map((_) => HealthDataAccess.READ).toList(),
      );

      if (hasPermissions == true) {
        _isAuthorized = true;
        return true;
      }

      // İzin iste - Android'de bu Health Connect izin ekranını açar
      final authorized = await _health.requestAuthorization(
        dataTypes,
        permissions: dataTypes.map((_) => HealthDataAccess.READ).toList(),
      );

      _isAuthorized = authorized;
      
      if (kDebugMode) {
        debugPrint('Health authorization result: $authorized');
      }
      
      return authorized;
    } catch (e, stackTrace) {
      // İzin hatası detaylı logla
      debugPrint('Health authorization error: $e');
      debugPrint('Stack trace: $stackTrace');
      _isAuthorized = false;
      return false;
    }
  }

  /// Bugünkü adım sayısını al
  Future<int> getTodaySteps() async {
    if (!_isAuthorized) {
      final authorized = await requestAuthorization();
      if (!authorized) return 0;
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final steps = await _health.getTotalStepsInInterval(startOfDay, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('Error getting steps: $e');
      return 0;
    }
  }

  /// Belirli bir tarih aralığındaki adımları al
  Future<int> getStepsInRange(DateTime start, DateTime end) async {
    if (!_isAuthorized) {
      final authorized = await requestAuthorization();
      if (!authorized) return 0;
    }

    try {
      final steps = await _health.getTotalStepsInInterval(start, end);
      return steps ?? 0;
    } catch (e) {
      debugPrint('Error getting steps in range: $e');
      return 0;
    }
  }

  /// Haftalık adım verilerini al (son 7 gün)
  Future<List<DailyStepData>> getWeeklySteps() async {
    if (!_isAuthorized) {
      final authorized = await requestAuthorization();
      if (!authorized) return [];
    }

    final List<DailyStepData> weeklyData = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      try {
        final steps = await _health.getTotalStepsInInterval(date, endOfDay);
        weeklyData.add(DailyStepData(
          date: date,
          steps: steps ?? 0,
        ));
      } catch (e) {
        weeklyData.add(DailyStepData(date: date, steps: 0));
      }
    }

    return weeklyData;
  }

  /// Bugünkü yakılan kaloriyi al
  Future<double> getTodayCaloriesBurned() async {
    if (!_isAuthorized) {
      final authorized = await requestAuthorization();
      if (!authorized) return 0;
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final dataType = Platform.isAndroid
          ? HealthDataType.ACTIVE_ENERGY_BURNED
          : HealthDataType.ACTIVE_ENERGY_BURNED;

      final data = await _health.getHealthDataFromTypes(
        types: [dataType],
        startTime: startOfDay,
        endTime: now,
      );

      double totalCalories = 0;
      for (final point in data) {
        if (point.value is NumericHealthValue) {
          totalCalories +=
              (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      return totalCalories;
    } catch (e) {
      debugPrint('Error getting calories: $e');
      return 0;
    }
  }

  /// Bugünkü yürüme/koşu mesafesini al (km)
  Future<double> getTodayDistance() async {
    if (!_isAuthorized) {
      final authorized = await requestAuthorization();
      if (!authorized) return 0;
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final dataType = Platform.isAndroid
          ? HealthDataType.DISTANCE_DELTA
          : HealthDataType.DISTANCE_WALKING_RUNNING;

      final data = await _health.getHealthDataFromTypes(
        types: [dataType],
        startTime: startOfDay,
        endTime: now,
      );

      double totalDistance = 0;
      for (final point in data) {
        if (point.value is NumericHealthValue) {
          totalDistance +=
              (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      // Metreyi kilometreye çevir
      return totalDistance / 1000;
    } catch (e) {
      debugPrint('Error getting distance: $e');
      return 0;
    }
  }

  /// Bugünkü kalp atış hızı ortalamasını al
  Future<int> getTodayAverageHeartRate() async {
    if (!_isAuthorized) {
      final authorized = await requestAuthorization();
      if (!authorized) return 0;
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startOfDay,
        endTime: now,
      );

      if (data.isEmpty) return 0;

      double total = 0;
      for (final point in data) {
        if (point.value is NumericHealthValue) {
          total += (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      return (total / data.length).round();
    } catch (e) {
      debugPrint('Error getting heart rate: $e');
      return 0;
    }
  }

  /// Bugünkü uyku süresini al (saat)
  Future<double> getTodaySleepHours() async {
    if (!_isAuthorized) {
      final authorized = await requestAuthorization();
      if (!authorized) return 0;
    }

    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final startOfYesterday =
          DateTime(yesterday.year, yesterday.month, yesterday.day, 18, 0);

      // Android'de SLEEP_IN_BED desteklenmiyor, sadece SLEEP_ASLEEP kullan
      final sleepTypes = Platform.isAndroid
          ? [HealthDataType.SLEEP_ASLEEP]
          : [
              HealthDataType.SLEEP_ASLEEP,
              HealthDataType.SLEEP_IN_BED,
            ];

      final data = await _health.getHealthDataFromTypes(
        types: sleepTypes,
        startTime: startOfYesterday,
        endTime: now,
      );

      double totalMinutes = 0;
      for (final point in data) {
        if (point.value is NumericHealthValue) {
          totalMinutes +=
              (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      return totalMinutes / 60; // Dakikayı saate çevir
    } catch (e) {
      // Uyku verisi opsiyonel, hataları sessizce yok say
      if (kDebugMode) {
        debugPrint('Sleep data not available: $e');
      }
      return 0;
    }
  }

  /// Tüm günlük sağlık verilerini al
  Future<HealthSummary> getDailySummary() async {
    final steps = await getTodaySteps();
    final calories = await getTodayCaloriesBurned();
    final distance = await getTodayDistance();
    final heartRate = await getTodayAverageHeartRate();
    final sleep = await getTodaySleepHours();

    return HealthSummary(
      steps: steps,
      caloriesBurned: calories,
      distanceKm: distance,
      averageHeartRate: heartRate,
      sleepHours: sleep,
      date: DateTime.now(),
    );
  }
}

/// Günlük adım verisi modeli
class DailyStepData {
  final DateTime date;
  final int steps;

  DailyStepData({required this.date, required this.steps});
}

/// Günlük sağlık özeti modeli
class HealthSummary {
  final int steps;
  final double caloriesBurned;
  final double distanceKm;
  final int averageHeartRate;
  final double sleepHours;
  final DateTime date;

  HealthSummary({
    required this.steps,
    required this.caloriesBurned,
    required this.distanceKm,
    required this.averageHeartRate,
    required this.sleepHours,
    required this.date,
  });
}

