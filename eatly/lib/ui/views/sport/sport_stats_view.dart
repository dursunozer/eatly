import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:fl_chart/fl_chart.dart';
import 'sport_stats_viewmodel.dart';
import '../../../core/theme/app_theme.dart';

class SportStatsView extends StackedView<SportStatsViewModel> {
  const SportStatsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SportStatsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: viewModel.navigateBack,
        ),
        title: const Text(
          'İstatistikler',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(context, viewModel),
                  const SizedBox(height: 20),
                  _buildSummaryCards(context, viewModel),
                  const SizedBox(height: 24),
                  _buildStepsChart(context, viewModel),
                  const SizedBox(height: 24),
                  _buildCaloriesChart(context, viewModel),
                  const SizedBox(height: 24),
                  _buildWaterChart(context, viewModel),
                  const SizedBox(height: 24),
                  _buildActivityDistribution(context, viewModel),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, SportStatsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          _PeriodButton(
            label: 'Hafta',
            isSelected: viewModel.selectedPeriod == 'week',
            onTap: () => viewModel.setPeriod('week'),
          ),
          _PeriodButton(
            label: 'Ay',
            isSelected: viewModel.selectedPeriod == 'month',
            onTap: () => viewModel.setPeriod('month'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, SportStatsViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Toplam Adım',
            value: viewModel.totalSteps.toString(),
            icon: Icons.directions_walk,
            color: AppTheme.primaryColor,
            trend: viewModel.stepsTrend,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Yakılan Kalori',
            value: '${viewModel.totalCalories.toInt()}',
            icon: Icons.local_fire_department,
            color: Colors.orange,
            trend: viewModel.caloriesTrend,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsChart(BuildContext context, SportStatsViewModel viewModel) {
    return _ChartCard(
      title: 'Adım Grafiği',
      subtitle: 'Günlük adım sayıları',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: viewModel.maxSteps.toDouble() * 1.2,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} adım',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < viewModel.weeklySteps.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          viewModel.getDayLabel(index),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: viewModel.weeklySteps.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final isToday = index == viewModel.weeklySteps.length - 1;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.steps.toDouble(),
                    color: isToday ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.5),
                    width: 24,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(BuildContext context, SportStatsViewModel viewModel) {
    return _ChartCard(
      title: 'Kalori Trendi',
      subtitle: 'Günlük yakılan kalori',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: viewModel.maxDailyCalories / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < viewModel.weeklyCalories.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          viewModel.getDayLabel(index),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (viewModel.weeklyCalories.length - 1).toDouble(),
            minY: 0,
            maxY: viewModel.maxDailyCalories * 1.2,
            lineBarsData: [
              LineChartBarData(
                spots: viewModel.weeklyCalories.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: Colors.orange,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.orange,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.orange.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterChart(BuildContext context, SportStatsViewModel viewModel) {
    return _ChartCard(
      title: 'Su Tüketimi',
      subtitle: 'Günlük su alımı (ml)',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: viewModel.waterGoal.toDouble() * 1.5,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} ml',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < viewModel.weeklyWater.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          viewModel.getDayLabel(index),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: viewModel.weeklyWater.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final reachedGoal = data.amountMl >= viewModel.waterGoal;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.amountMl.toDouble(),
                    color: reachedGoal ? Colors.blue : Colors.blue.withOpacity(0.5),
                    width: 24,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: viewModel.waterGoal.toDouble(),
                  color: Colors.blue.withOpacity(0.5),
                  strokeWidth: 2,
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    labelResolver: (line) => 'Hedef',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityDistribution(BuildContext context, SportStatsViewModel viewModel) {
    if (viewModel.activityDistribution.isEmpty) {
      return _ChartCard(
        title: 'Aktivite Dağılımı',
        subtitle: 'Bu dönemde aktivite yok',
        child: const SizedBox(
          height: 150,
          child: Center(
            child: Text(
              'Henüz aktivite verisi yok',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return _ChartCard(
      title: 'Aktivite Dağılımı',
      subtitle: 'Aktivite türlerine göre',
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: viewModel.activityDistribution.entries.map((entry) {
                    final color = _getActivityColor(entry.key);
                    return PieChartSectionData(
                      color: color,
                      value: entry.value.toDouble(),
                      title: '${entry.value}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: viewModel.activityDistribution.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getActivityColor(entry.key),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getActivityLabel(entry.key),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
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

  String _getActivityLabel(String type) {
    switch (type) {
      case 'running':
        return 'Koşu';
      case 'walking':
        return 'Yürüyüş';
      case 'cycling':
        return 'Bisiklet';
      case 'swimming':
        return 'Yüzme';
      case 'yoga':
        return 'Yoga';
      case 'workout':
        return 'Antrenman';
      case 'hiit':
        return 'HIIT';
      default:
        return 'Diğer';
    }
  }

  @override
  SportStatsViewModel viewModelBuilder(BuildContext context) => SportStatsViewModel();

  @override
  void onViewModelReady(SportStatsViewModel viewModel) {
    viewModel.initialize();
  }
}

// ==================== WIDGET'LAR ====================

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double trend;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = trend >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trend != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}${trend.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

