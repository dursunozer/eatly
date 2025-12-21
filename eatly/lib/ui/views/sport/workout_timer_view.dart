import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'workout_timer_viewmodel.dart';
import '../../../core/theme/app_theme.dart';

class WorkoutTimerView extends StackedView<WorkoutTimerViewModel> {
  const WorkoutTimerView({super.key});

  @override
  Widget builder(
    BuildContext context,
    WorkoutTimerViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: viewModel.navigateBack,
        ),
        title: const Text(
          'Antrenman Zamanlayıcı',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (viewModel.hasStarted)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: viewModel.resetWorkout,
            ),
        ],
      ),
      body: viewModel.isWorkoutComplete
          ? _buildCompletionScreen(context, viewModel)
          : _buildTimerScreen(context, viewModel),
    );
  }

  Widget _buildTimerScreen(BuildContext context, WorkoutTimerViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Exercise info card
          _buildCurrentExerciseCard(context, viewModel),
          const SizedBox(height: 32),

          // Timer circle
          _buildTimerCircle(context, viewModel),
          const SizedBox(height: 32),

          // Set/Rep info
          if (!viewModel.isResting) _buildSetRepInfo(context, viewModel),

          // Rest mode
          if (viewModel.isResting) _buildRestInfo(context, viewModel),

          const SizedBox(height: 32),

          // Control buttons
          _buildControlButtons(context, viewModel),

          const SizedBox(height: 24),

          // Quick rest buttons
          if (!viewModel.isResting) _buildQuickRestButtons(context, viewModel),

          const SizedBox(height: 24),

          // Exercise selector
          if (!viewModel.hasStarted) _buildExerciseSelector(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildCurrentExerciseCard(BuildContext context, WorkoutTimerViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.3),
            AppTheme.primaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            viewModel.currentExerciseIcon,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.currentExercise,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (viewModel.currentExerciseDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                viewModel.currentExerciseDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerCircle(BuildContext context, WorkoutTimerViewModel viewModel) {
    final isResting = viewModel.isResting;
    final color = isResting ? Colors.blue : AppTheme.primaryColor;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        SizedBox(
          width: 250,
          height: 250,
          child: CircularProgressIndicator(
            value: viewModel.progress,
            strokeWidth: 12,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        // Timer text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              viewModel.timerDisplay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              isResting ? 'DİNLENME' : 'ANTRENMAN',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSetRepInfo(BuildContext context, WorkoutTimerViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatCard(
          title: 'SET',
          value: '${viewModel.currentSet}/${viewModel.totalSets}',
          color: Colors.purple,
        ),
        _StatCard(
          title: 'TEKRAR',
          value: '${viewModel.currentRep}/${viewModel.totalReps}',
          color: Colors.orange,
        ),
        _StatCard(
          title: 'KALORİ',
          value: '${viewModel.caloriesBurned}',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildRestInfo(BuildContext context, WorkoutTimerViewModel viewModel) {
    return Column(
      children: [
        Text(
          'Sonraki set için hazırlan',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SmallButton(
              label: '-15s',
              onTap: () => viewModel.adjustRestTime(-15),
            ),
            const SizedBox(width: 16),
            _SmallButton(
              label: '+15s',
              onTap: () => viewModel.adjustRestTime(15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context, WorkoutTimerViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (viewModel.hasStarted && !viewModel.isResting)
          _ControlButton(
            icon: Icons.skip_previous,
            color: Colors.grey,
            onTap: viewModel.previousRep,
          ),
        const SizedBox(width: 24),
        _ControlButton(
          icon: viewModel.isTimerRunning ? Icons.pause : Icons.play_arrow,
          color: AppTheme.primaryColor,
          size: 80,
          onTap: viewModel.isTimerRunning
              ? viewModel.pauseTimer
              : viewModel.startTimer,
        ),
        const SizedBox(width: 24),
        if (viewModel.hasStarted && !viewModel.isResting)
          _ControlButton(
            icon: Icons.skip_next,
            color: Colors.grey,
            onTap: viewModel.nextRep,
          ),
      ],
    );
  }

  Widget _buildQuickRestButtons(BuildContext context, WorkoutTimerViewModel viewModel) {
    return Column(
      children: [
        Text(
          'Hızlı Dinlenme',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RestButton(
              seconds: 30,
              onTap: () => viewModel.startRest(30),
            ),
            const SizedBox(width: 12),
            _RestButton(
              seconds: 60,
              onTap: () => viewModel.startRest(60),
            ),
            const SizedBox(width: 12),
            _RestButton(
              seconds: 90,
              onTap: () => viewModel.startRest(90),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseSelector(BuildContext context, WorkoutTimerViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white24),
        const SizedBox(height: 16),
        const Text(
          'Egzersiz Seç',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: viewModel.exerciseList.map((exercise) {
            final isSelected = viewModel.currentExercise == exercise['name'];
            return GestureDetector(
              onTap: () => viewModel.selectExercise(exercise),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      exercise['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exercise['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Set/Rep ayarları
        Row(
          children: [
            Expanded(
              child: _AdjustableValue(
                label: 'Set',
                value: viewModel.totalSets,
                onDecrease: () => viewModel.adjustSets(-1),
                onIncrease: () => viewModel.adjustSets(1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AdjustableValue(
                label: 'Tekrar',
                value: viewModel.totalReps,
                onDecrease: () => viewModel.adjustReps(-1),
                onIncrease: () => viewModel.adjustReps(1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletionScreen(BuildContext context, WorkoutTimerViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 80,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Tebrikler!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Antrenmanı tamamladın',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 32),
            _CompletionStat(
              icon: Icons.timer,
              label: 'Toplam Süre',
              value: viewModel.totalTimeDisplay,
            ),
            const SizedBox(height: 16),
            _CompletionStat(
              icon: Icons.local_fire_department,
              label: 'Yakılan Kalori',
              value: '${viewModel.caloriesBurned} kcal',
            ),
            const SizedBox(height: 16),
            _CompletionStat(
              icon: Icons.fitness_center,
              label: 'Tamamlanan',
              value: '${viewModel.totalSets} set × ${viewModel.totalReps} tekrar',
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: viewModel.resetWorkout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tekrar Başla'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: viewModel.isBusy ? null : viewModel.saveAndExit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                    child: viewModel.isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Kaydet',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  WorkoutTimerViewModel viewModelBuilder(BuildContext context) =>
      WorkoutTimerViewModel();
}

// ==================== WIDGET'LAR ====================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.color,
    this.size = 56,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SmallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _RestButton extends StatelessWidget {
  final int seconds;
  final VoidCallback onTap;

  const _RestButton({required this.seconds, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Text(
          '${seconds}s',
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _AdjustableValue extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _AdjustableValue({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: onDecrease,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove, color: Colors.white, size: 20),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onIncrease,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppTheme.primaryColor, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CompletionStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

