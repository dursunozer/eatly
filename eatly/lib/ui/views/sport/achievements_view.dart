import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'achievements_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/sport_service.dart';

class AchievementsView extends StackedView<AchievementsViewModel> {
  const AchievementsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    AchievementsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : CustomScrollView(
              slivers: [
                _buildAppBar(context, viewModel),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSummaryCard(context, viewModel),
                      const SizedBox(height: 24),
                      _buildCategoryFilter(context, viewModel),
                      const SizedBox(height: 20),
                      _buildAchievementsList(context, viewModel),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar(BuildContext context, AchievementsViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
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
              'Rozetler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Başarımlarını görüntüle',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.amber.shade700,
                Colors.amber.shade900.withOpacity(0.5),
                const Color(0xFF1A1A2E),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 20,
                top: 60,
                child: Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AchievementsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade600,
            Colors.amber.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${viewModel.earnedCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/ ${viewModel.totalCount} rozet kazanıldı',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: viewModel.progressPercentage,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${(viewModel.progressPercentage * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tamamlandı',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, AchievementsViewModel viewModel) {
    final categories = {
      'all': 'Tümü',
      'steps': 'Adımlar',
      'workout': 'Antrenman',
      'water': 'Su',
      'calories': 'Kalori',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.entries.map((entry) {
          final isSelected = viewModel.selectedCategory == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => viewModel.setCategory(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.amber
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.amber
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(entry.key),
                      size: 18,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'steps':
        return Icons.directions_walk;
      case 'workout':
        return Icons.fitness_center;
      case 'water':
        return Icons.water_drop;
      case 'calories':
        return Icons.local_fire_department;
      default:
        return Icons.emoji_events;
    }
  }

  Widget _buildAchievementsList(BuildContext context, AchievementsViewModel viewModel) {
    final achievements = viewModel.filteredAchievements;

    if (achievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu kategoride rozet yok',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: achievements.map((achievement) {
        final isEarned = viewModel.isAchievementEarned(achievement.id);
        return _AchievementCard(
          achievement: achievement,
          isEarned: isEarned,
          earnedAt: isEarned ? viewModel.getEarnedDate(achievement.id) : null,
        );
      }).toList(),
    );
  }

  @override
  AchievementsViewModel viewModelBuilder(BuildContext context) =>
      AchievementsViewModel();

  @override
  void onViewModelReady(AchievementsViewModel viewModel) {
    viewModel.initialize();
  }
}

// ==================== WIDGET'LAR ====================

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isEarned;
  final DateTime? earnedAt;

  const _AchievementCard({
    required this.achievement,
    required this.isEarned,
    this.earnedAt,
  });

  IconData get _icon {
    switch (achievement.iconName) {
      case 'directions_walk':
        return Icons.directions_walk;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'water_drop':
        return Icons.water_drop;
      case 'waves':
        return Icons.waves;
      case 'pool':
        return Icons.pool;
      case 'whatshot':
        return Icons.whatshot;
      case 'military_tech':
        return Icons.military_tech;
      default:
        return Icons.emoji_events;
    }
  }

  Color get _categoryColor {
    switch (achievement.category) {
      case 'steps':
        return Colors.green;
      case 'workout':
        return Colors.purple;
      case 'water':
        return Colors.blue;
      case 'calories':
        return Colors.orange;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isEarned
            ? _categoryColor.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEarned
              ? _categoryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Badge icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: isEarned
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _categoryColor,
                              _categoryColor.withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: isEarned ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isEarned
                        ? [
                            BoxShadow(
                              color: _categoryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _icon,
                    color: isEarned ? Colors.white : Colors.white.withOpacity(0.3),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.nameTr,
                              style: TextStyle(
                                color: isEarned
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: isEarned
                                      ? Colors.amber
                                      : Colors.amber.withOpacity(0.5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${achievement.points}',
                                  style: TextStyle(
                                    color: isEarned
                                        ? Colors.amber
                                        : Colors.amber.withOpacity(0.5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.descriptionTr ?? '',
                        style: TextStyle(
                          color: isEarned
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white.withOpacity(0.3),
                          fontSize: 14,
                        ),
                      ),
                      if (earnedAt != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: _categoryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kazanıldı: ${_formatDate(earnedAt!)}',
                              style: TextStyle(
                                color: _categoryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lock overlay for not earned
          if (!isEarned)
            Positioned(
              top: 10,
              right: 10,
              child: Icon(
                Icons.lock_outline,
                color: Colors.white.withOpacity(0.2),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

