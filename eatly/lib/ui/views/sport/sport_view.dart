import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'sport_viewmodel.dart';
import '../../../core/theme/app_theme.dart';

class SportView extends StackedView<SportViewModel> {
  const SportView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SportViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Spor Aktiviteleri'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewModel.loadSportData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDailyGoalsCard(context, viewModel),
                    const SizedBox(height: 20),
                    _buildQuickActionsRow(context, viewModel),
                    const SizedBox(height: 20),
                    _buildActivitiesSection(context, viewModel),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityDialog(context, viewModel),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDailyGoalsCard(BuildContext context, SportViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Günlük Hedefler',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildGoalIndicator(
                    context,
                    'Adımlar',
                    viewModel.currentSteps,
                    viewModel.dailyStepGoal,
                    viewModel.stepProgress,
                    Icons.directions_walk,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildGoalIndicator(
                    context,
                    'Kalori',
                    viewModel.burnedCalories.toInt(),
                    viewModel.dailyCalorieGoal.toInt(),
                    viewModel.calorieProgress,
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalIndicator(
    BuildContext context,
    String title,
    int current,
    int goal,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 8.0,
          percent: progress.clamp(0.0, 1.0),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '$current / $goal',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsRow(BuildContext context, SportViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Koşu',
            Icons.directions_run,
            Colors.blue,
            () => _addQuickActivity(viewModel, 'Koşu', 30, 300),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Yürüyüş',
            Icons.directions_walk,
            Colors.green,
            () => _addQuickActivity(viewModel, 'Yürüyüş', 30, 150),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Bisiklet',
            Icons.directions_bike,
            Colors.orange,
            () => _addQuickActivity(viewModel, 'Bisiklet', 30, 250),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesSection(BuildContext context, SportViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Aktiviteler',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (viewModel.activities.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz aktivite eklenmemiş',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...viewModel.activities.map((activity) => _buildActivityCard(
                context,
                activity,
              )),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, SportActivity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(activity.name),
        subtitle: Text(
          '${activity.duration} dakika • ${activity.calories.toInt()} kcal',
        ),
        trailing: Text(
          _formatDate(activity.date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  void _addQuickActivity(
    SportViewModel viewModel,
    String name,
    int duration,
    double calories,
  ) {
    viewModel.addActivity(
      SportActivity(
        name: name,
        duration: duration,
        calories: calories,
        date: DateTime.now(),
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context, SportViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Aktivite Ekle'),
        content: const Text('Aktivite ekleme özelliği yakında...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  SportViewModel viewModelBuilder(BuildContext context) => SportViewModel();

  @override
  void onViewModelReady(SportViewModel viewModel) {
    viewModel.initialize();
  }
}