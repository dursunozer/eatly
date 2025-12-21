import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'health_service.dart';

/// Spor verilerini yöneten servis
class SportService {
  static SupabaseClient get _client => Supabase.instance.client;
  static final HealthService _healthService = HealthService();

  // ==================== AKTİVİTELER ====================

  /// Yeni aktivite ekle
  static Future<void> addActivity({
    required String name,
    required String activityType,
    required int durationMinutes,
    double? caloriesBurned,
    double? distanceKm,
    int? steps,
    String? notes,
    DateTime? activityDate,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    await _client.from('sport_activities').insert({
      'user_id': userId,
      'name': name,
      'activity_type': activityType,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned ?? _estimateCalories(activityType, durationMinutes),
      'distance_km': distanceKm,
      'steps': steps,
      'notes': notes,
      'activity_date': (activityDate ?? DateTime.now()).toIso8601String().split('T')[0],
      'source': 'manual',
    });
  }

  /// Aktiviteleri getir (son 30 gün)
  static Future<List<SportActivityData>> getActivities({int limit = 30}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('sport_activities')
        .select()
        .eq('user_id', userId)
        .order('activity_date', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((e) => SportActivityData.fromJson(e))
        .toList();
  }

  /// Bugünkü aktiviteleri getir
  static Future<List<SportActivityData>> getTodayActivities() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _client
        .from('sport_activities')
        .select()
        .eq('user_id', userId)
        .eq('activity_date', today)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => SportActivityData.fromJson(e))
        .toList();
  }

  /// Aktivite sil
  static Future<void> deleteActivity(String activityId) async {
    await _client.from('sport_activities').delete().eq('id', activityId);
  }

  /// Tahmini kalori hesapla
  static double _estimateCalories(String activityType, int minutes) {
    final caloriesPerMinute = {
      'running': 10.0,
      'walking': 4.0,
      'cycling': 7.0,
      'swimming': 8.0,
      'workout': 6.0,
      'yoga': 3.0,
      'hiit': 12.0,
      'other': 5.0,
    };
    return (caloriesPerMinute[activityType] ?? 5.0) * minutes;
  }

  // ==================== SU TAKİBİ ====================

  /// Su ekle
  static Future<void> addWaterIntake(int amountMl) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    await _client.from('water_intake').insert({
      'user_id': userId,
      'amount_ml': amountMl,
      'intake_date': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  /// Bugünkü su tüketimini getir
  static Future<int> getTodayWaterIntake() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _client
        .from('water_intake')
        .select('amount_ml')
        .eq('user_id', userId)
        .eq('intake_date', today);

    int total = 0;
    for (final row in response as List) {
      total += (row['amount_ml'] as int?) ?? 0;
    }
    return total;
  }

  /// Su hedefini getir
  static Future<int> getWaterGoal() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 2000;

    final response = await _client
        .from('water_goals')
        .select('daily_goal_ml')
        .eq('user_id', userId)
        .maybeSingle();

    return (response?['daily_goal_ml'] as int?) ?? 2000;
  }

  /// Su hedefini güncelle
  static Future<void> updateWaterGoal(int goalMl) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    await _client.from('water_goals').upsert({
      'user_id': userId,
      'daily_goal_ml': goalMl,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  /// Haftalık su verilerini getir
  static Future<List<DailyWaterData>> getWeeklyWaterData() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final startDate = DateTime(weekAgo.year, weekAgo.month, weekAgo.day);

    final response = await _client
        .from('water_intake')
        .select('intake_date, amount_ml')
        .eq('user_id', userId)
        .gte('intake_date', startDate.toIso8601String().split('T')[0])
        .lte('intake_date', now.toIso8601String().split('T')[0]);

    // Günlük toplam hesapla
    final Map<String, int> dailyTotals = {};
    for (final row in response as List) {
      final date = row['intake_date'] as String;
      final amount = (row['amount_ml'] as int?) ?? 0;
      dailyTotals[date] = (dailyTotals[date] ?? 0) + amount;
    }

    // Son 7 gün için veri oluştur
    final List<DailyWaterData> weeklyData = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateStr = date.toIso8601String().split('T')[0];
      weeklyData.add(DailyWaterData(
        date: date,
        amountMl: dailyTotals[dateStr] ?? 0,
      ));
    }

    return weeklyData;
  }

  // ==================== ADIM TAKİBİ ====================

  /// Bugünkü adımları getir (önce Health Connect, sonra DB)
  static Future<StepData> getTodaySteps() async {
    final userId = _client.auth.currentUser?.id;
    
    // Önce Health Connect'ten dene
    try {
      if (await _healthService.isHealthAvailable()) {
        final healthSteps = await _healthService.getTodaySteps();
        if (healthSteps > 0) {
          // DB'ye sync et
          await _syncStepsToDb(healthSteps);
          return StepData(
            steps: healthSteps,
            source: 'health_connect',
          );
        }
      }
    } catch (e) {
      debugPrint('Health Connect error: $e');
    }

    // DB'den getir
    if (userId == null) return StepData(steps: 0, source: 'manual');

    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client
        .from('daily_steps')
        .select()
        .eq('user_id', userId)
        .eq('step_date', today)
        .maybeSingle();

    return StepData(
      steps: (response?['step_count'] as int?) ?? 0,
      source: (response?['source'] as String?) ?? 'manual',
    );
  }

  /// Adımları DB'ye sync et
  static Future<void> _syncStepsToDb(int steps) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];

    await _client.from('daily_steps').upsert({
      'user_id': userId,
      'step_count': steps,
      'step_date': today,
      'source': 'health_connect',
      'synced_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,step_date');
  }

  /// Manuel adım ekle
  static Future<void> addManualSteps(int steps) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final today = DateTime.now().toIso8601String().split('T')[0];

    // Mevcut adımları al
    final response = await _client
        .from('daily_steps')
        .select('step_count')
        .eq('user_id', userId)
        .eq('step_date', today)
        .maybeSingle();

    final currentSteps = (response?['step_count'] as int?) ?? 0;

    await _client.from('daily_steps').upsert({
      'user_id': userId,
      'step_count': currentSteps + steps,
      'step_date': today,
      'source': 'manual',
      'synced_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,step_date');
  }

  /// Haftalık adım verilerini getir
  static Future<List<DailyStepData>> getWeeklyStepData() async {
    // Önce Health Connect'ten dene
    try {
      if (await _healthService.isHealthAvailable()) {
        await _healthService.requestAuthorization();
        return await _healthService.getWeeklySteps();
      }
    } catch (e) {
      debugPrint('Health Connect weekly error: $e');
    }

    // DB'den getir
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));

    final response = await _client
        .from('daily_steps')
        .select('step_date, step_count')
        .eq('user_id', userId)
        .gte('step_date', weekAgo.toIso8601String().split('T')[0])
        .lte('step_date', now.toIso8601String().split('T')[0]);

    final Map<String, int> dailySteps = {};
    for (final row in response as List) {
      dailySteps[row['step_date'] as String] = (row['step_count'] as int?) ?? 0;
    }

    final List<DailyStepData> weeklyData = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateStr = date.toIso8601String().split('T')[0];
      weeklyData.add(DailyStepData(
        date: date,
        steps: dailySteps[dateStr] ?? 0,
      ));
    }

    return weeklyData;
  }

  // ==================== SPOR HEDEFLERİ ====================

  /// Spor hedeflerini getir
  static Future<SportGoals> getSportGoals() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return SportGoals(dailyStepGoal: 10000, dailyCalorieBurnGoal: 500, weeklyWorkoutGoal: 3);
    }

    final response = await _client
        .from('sport_goals')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return SportGoals(dailyStepGoal: 10000, dailyCalorieBurnGoal: 500, weeklyWorkoutGoal: 3);
    }

    return SportGoals(
      dailyStepGoal: (response['daily_step_goal'] as int?) ?? 10000,
      dailyCalorieBurnGoal: (response['daily_calorie_burn_goal'] as num?)?.toDouble() ?? 500,
      weeklyWorkoutGoal: (response['weekly_workout_goal'] as int?) ?? 3,
    );
  }

  /// Spor hedeflerini güncelle
  static Future<void> updateSportGoals({
    int? dailyStepGoal,
    double? dailyCalorieBurnGoal,
    int? weeklyWorkoutGoal,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final currentGoals = await getSportGoals();

    await _client.from('sport_goals').upsert({
      'user_id': userId,
      'daily_step_goal': dailyStepGoal ?? currentGoals.dailyStepGoal,
      'daily_calorie_burn_goal': dailyCalorieBurnGoal ?? currentGoals.dailyCalorieBurnGoal,
      'weekly_workout_goal': weeklyWorkoutGoal ?? currentGoals.weeklyWorkoutGoal,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  // ==================== ANTRENMAN PROGRAMLARI ====================

  /// Tüm antrenman programlarını getir
  static Future<List<WorkoutProgram>> getWorkoutPrograms() async {
    final response = await _client
        .from('workout_programs')
        .select()
        .eq('is_active', true)
        .order('created_at');

    return (response as List).map((e) => WorkoutProgram.fromJson(e)).toList();
  }

  /// Program egzersizlerini getir
  static Future<List<WorkoutExercise>> getProgramExercises(String programId, {int? week, int? day}) async {
    var query = _client
        .from('workout_exercises')
        .select()
        .eq('program_id', programId);

    if (week != null) {
      query = query.eq('week_number', week);
    }
    if (day != null) {
      query = query.eq('day_of_week', day);
    }

    final response = await query.order('order_index');

    return (response as List).map((e) => WorkoutExercise.fromJson(e)).toList();
  }

  /// Egzersiz tamamlandı olarak işaretle
  static Future<void> completeExercise({
    required String programId,
    required String exerciseId,
    int setsCompleted = 0,
    int repsCompleted = 0,
    int durationSeconds = 0,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    await _client.from('user_workout_progress').insert({
      'user_id': userId,
      'program_id': programId,
      'exercise_id': exerciseId,
      'sets_completed': setsCompleted,
      'reps_completed': repsCompleted,
      'duration_seconds': durationSeconds,
      'notes': notes,
    });
  }

  /// Kullanıcının program ilerlemesini getir
  static Future<int> getProgramProgress(String programId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final totalExercises = await _client
        .from('workout_exercises')
        .select('id')
        .eq('program_id', programId);

    final completedExercises = await _client
        .from('user_workout_progress')
        .select('exercise_id')
        .eq('user_id', userId)
        .eq('program_id', programId);

    if ((totalExercises as List).isEmpty) return 0;

    final completedIds = (completedExercises as List).map((e) => e['exercise_id']).toSet();
    return ((completedIds.length / totalExercises.length) * 100).round();
  }

  // ==================== ROZETLER ====================

  /// Tüm rozetleri getir
  static Future<List<Achievement>> getAllAchievements() async {
    final response = await _client
        .from('achievements')
        .select()
        .eq('is_active', true)
        .order('category')
        .order('requirement_value');

    return (response as List).map((e) => Achievement.fromJson(e)).toList();
  }

  /// Kullanıcının kazandığı rozetleri getir
  static Future<List<UserAchievement>> getUserAchievements() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('user_achievements')
        .select('*, achievements(*)')
        .eq('user_id', userId);

    return (response as List).map((e) => UserAchievement.fromJson(e)).toList();
  }

  /// Rozet kazandır
  static Future<void> awardAchievement(String achievementId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

    await _client.from('user_achievements').upsert({
      'user_id': userId,
      'achievement_id': achievementId,
      'earned_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,achievement_id');
  }

  /// Rozet ilerlemesini güncelle
  static Future<void> updateAchievementProgress(String achievementId, int progress) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('user_achievements').upsert({
      'user_id': userId,
      'achievement_id': achievementId,
      'progress_value': progress,
    }, onConflict: 'user_id,achievement_id');
  }

  /// Rozet kontrolü ve kazandırma
  static Future<List<Achievement>> checkAndAwardAchievements() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final List<Achievement> newlyEarned = [];

    // Tüm rozetleri al
    final achievements = await getAllAchievements();
    final userAchievements = await getUserAchievements();
    final earnedIds = userAchievements.map((e) => e.achievementId).toSet();

    // Bugünkü verileri al
    final todaySteps = await getTodaySteps();
    final todayActivities = await getTodayActivities();
    final todayCalories = todayActivities.fold<double>(0, (sum, a) => sum + a.caloriesBurned);

    for (final achievement in achievements) {
      if (earnedIds.contains(achievement.id)) continue;

      bool earned = false;

      switch (achievement.category) {
        case 'steps':
          if (achievement.requirementType == 'daily') {
            earned = todaySteps.steps >= achievement.requirementValue;
          }
          break;
        case 'calories':
          if (achievement.requirementType == 'daily') {
            earned = todayCalories >= achievement.requirementValue;
          }
          break;
        case 'workout':
          if (achievement.requirementType == 'total' && achievement.requirementValue == 1) {
            earned = todayActivities.isNotEmpty;
          }
          break;
        case 'water':
          final todayWater = await getTodayWaterIntake();
          final waterGoal = await getWaterGoal();
          if (achievement.requirementType == 'daily') {
            earned = todayWater >= waterGoal;
          }
          break;
      }

      if (earned) {
        await awardAchievement(achievement.id);
        newlyEarned.add(achievement);
      }
    }

    return newlyEarned;
  }

  // ==================== GÜNLÜK ÖZET ====================

  /// Günlük spor özeti
  static Future<DailySportSummary> getDailySummary() async {
    final steps = await getTodaySteps();
    final activities = await getTodayActivities();
    final waterIntake = await getTodayWaterIntake();
    final waterGoal = await getWaterGoal();
    final goals = await getSportGoals();

    final totalCalories = activities.fold<double>(0, (sum, a) => sum + a.caloriesBurned);
    final totalDuration = activities.fold<int>(0, (sum, a) => sum + a.durationMinutes);

    return DailySportSummary(
      steps: steps.steps,
      stepGoal: goals.dailyStepGoal,
      caloriesBurned: totalCalories,
      calorieGoal: goals.dailyCalorieBurnGoal,
      waterIntakeMl: waterIntake,
      waterGoalMl: waterGoal,
      workoutMinutes: totalDuration,
      activitiesCount: activities.length,
    );
  }
}

// ==================== VERİ MODELLERİ ====================

class SportActivityData {
  final String id;
  final String name;
  final String activityType;
  final int durationMinutes;
  final double caloriesBurned;
  final double? distanceKm;
  final int? steps;
  final String? notes;
  final String source;
  final DateTime activityDate;
  final DateTime createdAt;

  SportActivityData({
    required this.id,
    required this.name,
    required this.activityType,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.distanceKm,
    this.steps,
    this.notes,
    required this.source,
    required this.activityDate,
    required this.createdAt,
  });

  factory SportActivityData.fromJson(Map<String, dynamic> json) {
    return SportActivityData(
      id: json['id'] as String,
      name: json['name'] as String,
      activityType: json['activity_type'] as String,
      durationMinutes: json['duration_minutes'] as int,
      caloriesBurned: (json['calories_burned'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      steps: json['steps'] as int?,
      notes: json['notes'] as String?,
      source: json['source'] as String? ?? 'manual',
      activityDate: DateTime.parse(json['activity_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class StepData {
  final int steps;
  final String source;

  StepData({required this.steps, required this.source});
}

class DailyWaterData {
  final DateTime date;
  final int amountMl;

  DailyWaterData({required this.date, required this.amountMl});
}

class SportGoals {
  final int dailyStepGoal;
  final double dailyCalorieBurnGoal;
  final int weeklyWorkoutGoal;

  SportGoals({
    required this.dailyStepGoal,
    required this.dailyCalorieBurnGoal,
    required this.weeklyWorkoutGoal,
  });
}

class WorkoutProgram {
  final String id;
  final String name;
  final String nameTr;
  final String? description;
  final String? descriptionTr;
  final String difficultyLevel;
  final int durationWeeks;
  final String category;
  final String? imageUrl;

  WorkoutProgram({
    required this.id,
    required this.name,
    required this.nameTr,
    this.description,
    this.descriptionTr,
    required this.difficultyLevel,
    required this.durationWeeks,
    required this.category,
    this.imageUrl,
  });

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      id: json['id'] as String,
      name: json['name'] as String,
      nameTr: json['name_tr'] as String,
      description: json['description'] as String?,
      descriptionTr: json['description_tr'] as String?,
      difficultyLevel: json['difficulty_level'] as String,
      durationWeeks: json['duration_weeks'] as int,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class WorkoutExercise {
  final String id;
  final String programId;
  final String name;
  final String nameTr;
  final String? description;
  final String? descriptionTr;
  final String? muscleGroup;
  final int sets;
  final int reps;
  final int? durationSeconds;
  final int restSeconds;
  final int? dayOfWeek;
  final int weekNumber;
  final int orderIndex;
  final String? videoUrl;
  final String? imageUrl;
  final double caloriesPerSet;

  WorkoutExercise({
    required this.id,
    required this.programId,
    required this.name,
    required this.nameTr,
    this.description,
    this.descriptionTr,
    this.muscleGroup,
    required this.sets,
    required this.reps,
    this.durationSeconds,
    required this.restSeconds,
    this.dayOfWeek,
    required this.weekNumber,
    required this.orderIndex,
    this.videoUrl,
    this.imageUrl,
    required this.caloriesPerSet,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as String,
      programId: json['program_id'] as String,
      name: json['name'] as String,
      nameTr: json['name_tr'] as String,
      description: json['description'] as String?,
      descriptionTr: json['description_tr'] as String?,
      muscleGroup: json['muscle_group'] as String?,
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as int? ?? 10,
      durationSeconds: json['duration_seconds'] as int?,
      restSeconds: json['rest_seconds'] as int? ?? 60,
      dayOfWeek: json['day_of_week'] as int?,
      weekNumber: json['week_number'] as int? ?? 1,
      orderIndex: json['order_index'] as int? ?? 0,
      videoUrl: json['video_url'] as String?,
      imageUrl: json['image_url'] as String?,
      caloriesPerSet: (json['calories_per_set'] as num?)?.toDouble() ?? 5,
    );
  }
}

class Achievement {
  final String id;
  final String code;
  final String name;
  final String nameTr;
  final String? description;
  final String? descriptionTr;
  final String category;
  final String iconName;
  final int requirementValue;
  final String requirementType;
  final int points;

  Achievement({
    required this.id,
    required this.code,
    required this.name,
    required this.nameTr,
    this.description,
    this.descriptionTr,
    required this.category,
    required this.iconName,
    required this.requirementValue,
    required this.requirementType,
    required this.points,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      nameTr: json['name_tr'] as String,
      description: json['description'] as String?,
      descriptionTr: json['description_tr'] as String?,
      category: json['category'] as String,
      iconName: json['icon_name'] as String? ?? 'emoji_events',
      requirementValue: json['requirement_value'] as int,
      requirementType: json['requirement_type'] as String,
      points: json['points'] as int? ?? 10,
    );
  }
}

class UserAchievement {
  final String id;
  final String achievementId;
  final DateTime earnedAt;
  final int progressValue;
  final Achievement? achievement;

  UserAchievement({
    required this.id,
    required this.achievementId,
    required this.earnedAt,
    required this.progressValue,
    this.achievement,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'] as String,
      achievementId: json['achievement_id'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      progressValue: json['progress_value'] as int? ?? 0,
      achievement: json['achievements'] != null
          ? Achievement.fromJson(json['achievements'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DailySportSummary {
  final int steps;
  final int stepGoal;
  final double caloriesBurned;
  final double calorieGoal;
  final int waterIntakeMl;
  final int waterGoalMl;
  final int workoutMinutes;
  final int activitiesCount;

  DailySportSummary({
    required this.steps,
    required this.stepGoal,
    required this.caloriesBurned,
    required this.calorieGoal,
    required this.waterIntakeMl,
    required this.waterGoalMl,
    required this.workoutMinutes,
    required this.activitiesCount,
  });

  double get stepProgress => stepGoal > 0 ? (steps / stepGoal).clamp(0.0, 1.0) : 0;
  double get calorieProgress => calorieGoal > 0 ? (caloriesBurned / calorieGoal).clamp(0.0, 1.0) : 0;
  double get waterProgress => waterGoalMl > 0 ? (waterIntakeMl / waterGoalMl).clamp(0.0, 1.0) : 0;
}

