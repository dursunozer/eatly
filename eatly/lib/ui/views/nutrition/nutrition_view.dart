import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import 'nutrition_viewmodel.dart';

class NutritionView extends StatelessWidget {
  const NutritionView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NutritionViewModel>.reactive(
      viewModelBuilder: () => NutritionViewModel(),
      builder: (context, model, child) {
        final s = model.dailySummary;
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(title: const Text('Beslenme Detayları')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _macroCard(context, s),
                const SizedBox(height: 20),
                _vitaminCard(s),
                const SizedBox(height: 20),
                _mineralCard(s),
                const SizedBox(height: 20),
                _pieChart(s),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _macroCard(BuildContext context, summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Makro Besinler',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _macroRow(
              'Kalori',
              summary.totalCalories,
              summary.targetCalories,
              'kcal',
              AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            _macroRow(
              'Protein',
              summary.totalProtein,
              summary.targetProtein,
              'g',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _macroRow(
              'Karbonhidrat',
              summary.totalCarbs,
              summary.targetCarbs,
              'g',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _macroRow(
              'Yağ',
              summary.totalFat,
              summary.targetFat,
              'g',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroRow(
    String label,
    double current,
    double target,
    String unit,
    Color color,
  ) {
    final progress = (current / target).clamp(0, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 8,
          percent: progress.toDouble(),
          backgroundColor: Colors.grey.shade200,
          progressColor: color,
          barRadius: const Radius.circular(4),
        ),
      ],
    );
  }

  Widget _vitaminCard(summary) {
    final v = summary.totalVitamins;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vitaminler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _nutrientRow('Vitamin A', v['A'] ?? 0, 900, 'μg'),
            _nutrientRow('Vitamin B12', v['B12'] ?? 0, 2.4, 'μg'),
            _nutrientRow('Vitamin C', v['C'] ?? 0, 90, 'mg'),
            _nutrientRow('Vitamin D', v['D'] ?? 0, 20, 'μg'),
          ],
        ),
      ),
    );
  }

  Widget _mineralCard(summary) {
    final m = summary.totalMinerals;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mineraller',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _nutrientRow('Kalsiyum', m['Kalsiyum'] ?? 0, 1000, 'mg'),
            _nutrientRow('Demir', m['Demir'] ?? 0, 18, 'mg'),
            _nutrientRow('Fosfor', m['Fosfor'] ?? 0, 700, 'mg'),
            _nutrientRow('Potasyum', m['Potasyum'] ?? 0, 3500, 'mg'),
          ],
        ),
      ),
    );
  }

  Widget _nutrientRow(String name, double current, double daily, String unit) {
    final percentage = ((current / daily) * 100).clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(name, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${current.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _colorFor(percentage.toDouble()).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '%${percentage.toInt()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _colorFor(percentage.toDouble()),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(double p) {
    if (p < 50) return Colors.red;
    if (p < 80) return Colors.orange;
    return AppTheme.primaryColor;
  }

  Widget _pieChart(summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: summary.totalProtein,
                  title:
                      'Protein\n${(summary.totalProtein * 4 / (summary.totalCalories == 0 ? 1 : summary.totalCalories) * 100).toStringAsFixed(0)}%',
                  color: Colors.blue,
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: summary.totalCarbs,
                  title:
                      'Karb\n${(summary.totalCarbs * 4 / (summary.totalCalories == 0 ? 1 : summary.totalCalories) * 100).toStringAsFixed(0)}%',
                  color: Colors.orange,
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: summary.totalFat,
                  title:
                      'Yağ\n${(summary.totalFat * 9 / (summary.totalCalories == 0 ? 1 : summary.totalCalories) * 100).toStringAsFixed(0)}%',
                  color: Colors.purple,
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ),
    );
  }
}
