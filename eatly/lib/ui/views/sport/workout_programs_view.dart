import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'workout_programs_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/sport_service.dart';

class WorkoutProgramsView extends StackedView<WorkoutProgramsViewModel> {
  const WorkoutProgramsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    WorkoutProgramsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : viewModel.selectedProgram != null
              ? _buildProgramDetail(context, viewModel)
              : _buildProgramsList(context, viewModel),
    );
  }

  Widget _buildProgramsList(BuildContext context, WorkoutProgramsViewModel viewModel) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: true,
          backgroundColor: AppTheme.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: viewModel.navigateBack,
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            title: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Antrenman Programları',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Hedefinize uygun programları keşfedin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.shade600,
                    Colors.teal.shade800,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: 20,
                    child: Icon(
                      Icons.fitness_center,
                      size: 150,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildCategoryFilter(context, viewModel),
              const SizedBox(height: 20),
              ...viewModel.filteredPrograms.map(
                (program) => _ProgramCard(
                  program: program,
                  progress: viewModel.getProgramProgress(program.id),
                  onTap: () => viewModel.selectProgram(program),
                ),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context, WorkoutProgramsViewModel viewModel) {
    final categories = {
      'all': 'Tümü',
      'general': 'Genel',
      'weight_loss': 'Kilo Verme',
      'muscle_gain': 'Kas Geliştirme',
      'flexibility': 'Esneklik',
      'cardio': 'Kardiyo',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.entries.map((entry) {
          final isSelected = viewModel.selectedCategory == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => viewModel.setCategory(entry.key),
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgramDetail(BuildContext context, WorkoutProgramsViewModel viewModel) {
    final program = viewModel.selectedProgram!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: _getCategoryColor(program.category),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: viewModel.clearSelection,
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            title: Text(
              program.nameTr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCategoryColor(program.category),
                    _getCategoryColor(program.category).withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: 40,
                    child: Icon(
                      _getCategoryIcon(program.category),
                      size: 150,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildProgramInfo(context, program, viewModel),
              const SizedBox(height: 24),
              _buildWeekSelector(context, viewModel),
              const SizedBox(height: 16),
              _buildExercisesList(context, viewModel),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildProgramInfo(
    BuildContext context,
    WorkoutProgram program,
    WorkoutProgramsViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (program.descriptionTr != null) ...[
            Text(
              program.descriptionTr!,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              _InfoChip(
                icon: Icons.schedule,
                label: '${program.durationWeeks} Hafta',
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.signal_cellular_alt,
                label: _getDifficultyLabel(program.difficultyLevel),
                color: _getDifficultyColor(program.difficultyLevel),
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.local_fire_department,
                label: _getCategoryLabel(program.category),
                color: _getCategoryColor(program.category),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'İlerleme',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${viewModel.getProgramProgress(program.id)}%',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: viewModel.getProgramProgress(program.id) / 100,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector(BuildContext context, WorkoutProgramsViewModel viewModel) {
    final program = viewModel.selectedProgram!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hafta Seçin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(program.durationWeeks, (index) {
              final week = index + 1;
              final isSelected = viewModel.selectedWeek == week;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => viewModel.selectWeek(week),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Text(
                      'Hafta $week',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context, WorkoutProgramsViewModel viewModel) {
    final exercises = viewModel.weekExercises;

    if (exercises.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.fitness_center, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Bu hafta için egzersiz bulunamadı',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Günlere göre grupla
    final Map<int, List<WorkoutExercise>> byDay = {};
    for (final exercise in exercises) {
      final day = exercise.dayOfWeek ?? 0;
      byDay[day] = [...(byDay[day] ?? []), exercise];
    }

    final dayNames = ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Egzersizler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...byDay.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.key > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    dayNames[entry.key],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ...entry.value.map((exercise) => _ExerciseCard(
                    exercise: exercise,
                    onStart: () => viewModel.startExercise(exercise),
                  )),
            ],
          );
        }),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'weight_loss':
        return Colors.red.shade400;
      case 'muscle_gain':
        return Colors.blue.shade600;
      case 'flexibility':
        return Colors.purple.shade400;
      case 'cardio':
        return Colors.orange.shade400;
      default:
        return Colors.teal.shade400;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'weight_loss':
        return Icons.local_fire_department;
      case 'muscle_gain':
        return Icons.fitness_center;
      case 'flexibility':
        return Icons.self_improvement;
      case 'cardio':
        return Icons.directions_run;
      default:
        return Icons.sports_gymnastics;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'weight_loss':
        return 'Kilo Verme';
      case 'muscle_gain':
        return 'Kas Geliştirme';
      case 'flexibility':
        return 'Esneklik';
      case 'cardio':
        return 'Kardiyo';
      default:
        return 'Genel';
    }
  }

  String _getDifficultyLabel(String level) {
    switch (level) {
      case 'beginner':
        return 'Başlangıç';
      case 'intermediate':
        return 'Orta';
      case 'advanced':
        return 'İleri';
      default:
        return level;
    }
  }

  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  WorkoutProgramsViewModel viewModelBuilder(BuildContext context) =>
      WorkoutProgramsViewModel();

  @override
  void onViewModelReady(WorkoutProgramsViewModel viewModel) {
    viewModel.initialize();
  }
}

// ==================== WIDGET'LAR ====================

class _ProgramCard extends StatelessWidget {
  final WorkoutProgram program;
  final int progress;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.program,
    required this.progress,
    required this.onTap,
  });

  Color get _categoryColor {
    switch (program.category) {
      case 'weight_loss':
        return Colors.red.shade400;
      case 'muscle_gain':
        return Colors.blue.shade600;
      case 'flexibility':
        return Colors.purple.shade400;
      case 'cardio':
        return Colors.orange.shade400;
      default:
        return Colors.teal.shade400;
    }
  }

  IconData get _categoryIcon {
    switch (program.category) {
      case 'weight_loss':
        return Icons.local_fire_department;
      case 'muscle_gain':
        return Icons.fitness_center;
      case 'flexibility':
        return Icons.self_improvement;
      case 'cardio':
        return Icons.directions_run;
      default:
        return Icons.sports_gymnastics;
    }
  }

  String get _difficultyLabel {
    switch (program.difficultyLevel) {
      case 'beginner':
        return 'Başlangıç';
      case 'intermediate':
        return 'Orta';
      case 'advanced':
        return 'İleri';
      default:
        return program.difficultyLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _categoryColor.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _categoryColor,
                    _categoryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_categoryIcon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.nameTr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${program.durationWeeks} Hafta • $_difficultyLabel',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
            if (progress > 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'İlerleme',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          '$progress%',
                          style: TextStyle(
                            color: _categoryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: _categoryColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(_categoryColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final VoidCallback onStart;

  const _ExerciseCard({
    required this.exercise,
    required this.onStart,
  });

  IconData get _muscleIcon {
    switch (exercise.muscleGroup) {
      case 'chest':
        return Icons.sports_gymnastics;
      case 'back':
        return Icons.accessibility_new;
      case 'legs':
        return Icons.directions_walk;
      case 'arms':
        return Icons.fitness_center;
      case 'core':
        return Icons.straighten;
      case 'full_body':
        return Icons.accessibility;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_muscleIcon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.nameTr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.durationSeconds != null
                      ? '${exercise.sets} set × ${exercise.durationSeconds}s'
                      : '${exercise.sets} set × ${exercise.reps} tekrar',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (exercise.descriptionTr != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      exercise.descriptionTr!,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onStart,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

