import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'sport_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/sport_service.dart';

class SportView extends StackedView<SportViewModel> {
  const SportView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SportViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              onRefresh: viewModel.refreshData,
              color: AppTheme.primaryColor,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBar(context, viewModel),
                  SliverPadding(
                padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildDailySummaryCards(context, viewModel),
                        const SizedBox(height: 20),
                        _buildQuickActions(context, viewModel),
                        const SizedBox(height: 20),
                        _buildWaterTracker(context, viewModel),
                        const SizedBox(height: 20),
                        _buildFeatureCards(context, viewModel),
                    const SizedBox(height: 20),
                        _buildRecentActivities(context, viewModel),
                    const SizedBox(height: 20),
                        _buildAddActivityButton(context, viewModel),
                        const SizedBox(height: 100),
                      ]),
              ),
            ),
                ],
              ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, SportViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spor & Aktivite',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${viewModel.activitiesCount} aktivite bugün',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
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
                    AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
                const Color(0xFF2E7D32),
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
      actions: [
        IconButton(
          icon: Icon(
            viewModel.isHealthConnected ? Icons.link : Icons.link_off,
            color: Colors.white,
        ),
          onPressed: viewModel.connectHealthConnect,
          tooltip: viewModel.isHealthConnected
              ? 'Health Connect Bağlı'
              : 'Health Connect\'e Bağlan',
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart, color: Colors.white),
          onPressed: viewModel.navigateToSportStats,
          tooltip: 'İstatistikler',
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _showAddActivitySheet(context, viewModel),
          tooltip: 'Aktivite Ekle',
        ),
      ],
    );
  }

  Widget _buildDailySummaryCards(BuildContext context, SportViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Adımlar',
            value: '${viewModel.currentSteps}',
            target: '/ ${viewModel.dailyStepGoal}',
            progress: viewModel.stepProgress,
            icon: Icons.directions_walk,
            color: AppTheme.primaryColor,
            onTap: () => _showGoalEditDialog(context, viewModel, 'steps'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Kalori',
            value: '${viewModel.burnedCalories.toInt()}',
            target: '/ ${viewModel.dailyCalorieGoal.toInt()} kcal',
            progress: viewModel.calorieProgress,
            icon: Icons.local_fire_department,
            color: Colors.orange,
            onTap: () => _showGoalEditDialog(context, viewModel, 'calories'),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterTracker(BuildContext context, SportViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
          ),
                    child: const Icon(Icons.water_drop, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Su Tüketimi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${viewModel.waterIntake} / ${viewModel.waterGoal} ml',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CircularPercentIndicator(
                radius: 35,
                lineWidth: 6,
                percent: viewModel.waterProgress,
                center: Text(
                  '${(viewModel.waterProgress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                progressColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _WaterButton(amount: 200, onTap: () => viewModel.addWater(200)),
              _WaterButton(amount: 300, onTap: () => viewModel.addWater(300)),
              _WaterButton(amount: 500, onTap: () => viewModel.addWater(500)),
              _WaterButton(
                amount: 0,
                isCustom: true,
                onTap: () => _showCustomWaterDialog(context, viewModel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, SportViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı Aktivite',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickActionChip(
                label: 'Koşu',
                icon: Icons.directions_run,
                color: Colors.red.shade400,
                onTap: () => viewModel.addQuickActivity('Koşu', 'running', 30, 300),
              ),
              _QuickActionChip(
                label: 'Yürüyüş',
                icon: Icons.directions_walk,
                color: AppTheme.primaryColor,
                onTap: () => viewModel.addQuickActivity('Yürüyüş', 'walking', 30, 150),
              ),
              _QuickActionChip(
                label: 'Bisiklet',
                icon: Icons.directions_bike,
                color: Colors.orange,
                onTap: () => viewModel.addQuickActivity('Bisiklet', 'cycling', 30, 250),
              ),
              _QuickActionChip(
                label: 'Yüzme',
                icon: Icons.pool,
                color: Colors.blue,
                onTap: () => viewModel.addQuickActivity('Yüzme', 'swimming', 30, 280),
              ),
              _QuickActionChip(
                label: 'Yoga',
                icon: Icons.self_improvement,
                color: Colors.purple,
                onTap: () => viewModel.addQuickActivity('Yoga', 'yoga', 30, 100),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards(BuildContext context, SportViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keşfet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                title: 'Antrenman',
                subtitle: 'Zamanlayıcı',
                icon: Icons.timer,
                gradient: [Colors.purple.shade400, Colors.purple.shade700],
                onTap: viewModel.navigateToWorkoutTimer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                title: 'Programlar',
                subtitle: '${viewModel.programs.length} program',
                icon: Icons.fitness_center,
                gradient: [Colors.teal.shade400, Colors.teal.shade700],
                onTap: viewModel.navigateToWorkoutPrograms,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                title: 'İstatistikler',
                subtitle: 'Haftalık rapor',
                icon: Icons.bar_chart,
                gradient: [Colors.indigo.shade400, Colors.indigo.shade700],
                onTap: viewModel.navigateToSportStats,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                title: 'Rozetler',
                subtitle: '${viewModel.earnedAchievementsCount}/${viewModel.totalAchievementsCount}',
                icon: Icons.emoji_events,
                gradient: [Colors.amber.shade400, Colors.amber.shade700],
                onTap: viewModel.navigateToAchievements,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context, SportViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
          'Son Aktiviteler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            if (viewModel.activities.isNotEmpty)
              TextButton(
                onPressed: () {},
                child: const Text('Tümünü Gör'),
              ),
          ],
                  ),
        const SizedBox(height: 12),
        if (viewModel.activities.isEmpty)
          _EmptyActivitiesCard()
        else
          ...viewModel.activities.take(5).map(
                (activity) => _ActivityCard(
                  activity: activity,
                  onDelete: () => viewModel.deleteActivity(activity.id),
                ),
          ),
      ],
    );
  }

  Widget _buildAddActivityButton(BuildContext context, SportViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => _showAddActivitySheet(context, viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        icon: const Icon(Icons.add, color: Colors.white, size: 24),
        label: const Text(
          'Yeni Aktivite Ekle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddActivitySheet(BuildContext context, SportViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddActivitySheet(viewModel: viewModel),
    );
  }

  void _showGoalEditDialog(
      BuildContext context, SportViewModel viewModel, String type) {
    final controller = TextEditingController(
      text: type == 'steps'
          ? viewModel.dailyStepGoal.toString()
          : viewModel.dailyCalorieGoal.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'steps' ? 'Adım Hedefi' : 'Kalori Hedefi'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: type == 'steps' ? 'Günlük adım hedefi' : 'Günlük kalori hedefi',
            suffixText: type == 'steps' ? 'adım' : 'kcal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                if (type == 'steps') {
                  viewModel.updateStepGoal(value);
    } else {
                  viewModel.updateCalorieGoal(value.toDouble());
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCustomWaterDialog(BuildContext context, SportViewModel viewModel) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Su Ekle'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Miktar (ml)',
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                viewModel.addWater(amount);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Ekle', style: TextStyle(color: Colors.white)),
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

// ==================== WIDGET'LAR ====================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String target;
  final double progress;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.target,
    required this.progress,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                CircularPercentIndicator(
                  radius: 25,
                  lineWidth: 4,
                  percent: progress.clamp(0.0, 1.0),
                  center: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  progressColor: color,
                  backgroundColor: color.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    target,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
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
}

class _WaterButton extends StatelessWidget {
  final int amount;
  final bool isCustom;
  final VoidCallback onTap;

  const _WaterButton({
    required this.amount,
    this.isCustom = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          isCustom ? '+' : '+${amount}ml',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final SportActivityData activity;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.activity,
    required this.onDelete,
  });

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'running':
        return Icons.directions_run;
      case 'walking':
        return Icons.directions_walk;
      case 'cycling':
        return Icons.directions_bike;
      case 'swimming':
        return Icons.pool;
      case 'yoga':
        return Icons.self_improvement;
      case 'workout':
        return Icons.fitness_center;
      case 'hiit':
        return Icons.flash_on;
      default:
        return Icons.sports;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'running':
        return Colors.red.shade400;
      case 'walking':
        return Colors.green.shade400;
      case 'cycling':
        return Colors.orange.shade400;
      case 'swimming':
        return Colors.blue.shade400;
      case 'yoga':
        return Colors.purple.shade400;
      case 'workout':
        return Colors.teal.shade400;
      case 'hiit':
        return Colors.pink.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(activityDay).inDays;

    if (difference == 0) return 'Bugün';
    if (difference == 1) return 'Dün';
    return '$difference gün önce';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getActivityColor(activity.activityType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getActivityIcon(activity.activityType), color: color),
        ),
        title: Text(
          activity.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${activity.durationMinutes} dk • ${activity.caloriesBurned.toInt()} kcal',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(activity.activityDate),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivitiesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz aktivite yok',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk aktiviteni ekleyerek başla!',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddActivitySheet extends StatefulWidget {
  final SportViewModel viewModel;

  const _AddActivitySheet({required this.viewModel});

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final _nameController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _caloriesController = TextEditingController();
  String _selectedType = 'workout';

  final _activityTypes = {
    'running': 'Koşu',
    'walking': 'Yürüyüş',
    'cycling': 'Bisiklet',
    'swimming': 'Yüzme',
    'workout': 'Antrenman',
    'yoga': 'Yoga',
    'hiit': 'HIIT',
    'other': 'Diğer',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Yeni Aktivite',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Aktivite Adı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.sports),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Aktivite Türü',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _activityTypes.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Süre',
                      suffixText: 'dk',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.timer),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kalori (opsiyonel)',
                      suffixText: 'kcal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.local_fire_department),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aktivite Ekle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _saveActivity() async {
    final name = _nameController.text.trim();
    final duration = int.tryParse(_durationController.text) ?? 30;
    final calories = double.tryParse(_caloriesController.text);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivite adı gerekli')),
      );
      return;
    }

    try {
      await SportService.addActivity(
        name: name,
        activityType: _selectedType,
        durationMinutes: duration,
        caloriesBurned: calories,
      );

      await widget.viewModel.refreshData();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
