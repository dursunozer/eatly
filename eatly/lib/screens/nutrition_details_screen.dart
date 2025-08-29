import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/daily_summary.dart';
import '../models/food_item.dart';
import 'package:intl/intl.dart';

class NutritionDetailsScreen extends StatefulWidget {
  const NutritionDetailsScreen({super.key});

  @override
  State<NutritionDetailsScreen> createState() => _NutritionDetailsScreenState();
}

class _NutritionDetailsScreenState extends State<NutritionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  // Örnek veri
  final DailySummary _dailySummary = DailySummary(
    date: DateTime.now(),
    foods: [
      FoodItem(
        id: '1',
        name: 'Kahvaltı - Yumurta',
        imagePath: '',
        consumedAt: DateTime.now().subtract(const Duration(hours: 4)),
        portion: 100,
        nutritionInfo: NutritionInfo(
          calories: 155,
          protein: 13,
          carbs: 1.1,
          fat: 11,
          fiber: 0,
          vitamins: {'A': 540, 'D': 2, 'B12': 0.9},
          minerals: {'Demir': 1.8, 'Kalsiyum': 56},
        ),
      ),
      FoodItem(
        id: '2',
        name: 'Öğle - Tavuk Göğsü',
        imagePath: '',
        consumedAt: DateTime.now().subtract(const Duration(hours: 1)),
        portion: 150,
        nutritionInfo: NutritionInfo(
          calories: 246,
          protein: 46,
          carbs: 0,
          fat: 5.4,
          fiber: 0,
          vitamins: {'B6': 0.9, 'B3': 13.7},
          minerals: {'Fosfor': 228, 'Potasyum': 256},
        ),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Beslenme Detayları'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Özet'),
            Tab(text: 'Detaylar'),
            Tab(text: 'Grafikler'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSummaryTab(), _buildDetailsTab(), _buildChartsTab()],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateSelector(),
          const SizedBox(height: 20),
          _buildMacroSummaryCard(),
          const SizedBox(height: 20),
          _buildMealTimeline(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final formatter = DateFormat('dd MMMM yyyy', 'tr_TR');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.subtract(
                    const Duration(days: 1),
                  );
                });
              },
            ),
            Text(
              formatter.format(_selectedDate),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _selectedDate.day < DateTime.now().day
                  ? () {
                      setState(() {
                        _selectedDate = _selectedDate.add(
                          const Duration(days: 1),
                        );
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSummaryCard() {
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
            _buildMacroProgressBar(
              'Kalori',
              _dailySummary.totalCalories,
              _dailySummary.targetCalories,
              'kcal',
              AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            _buildMacroProgressBar(
              'Protein',
              _dailySummary.totalProtein,
              _dailySummary.targetProtein,
              'g',
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildMacroProgressBar(
              'Karbonhidrat',
              _dailySummary.totalCarbs,
              _dailySummary.targetCarbs,
              'g',
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildMacroProgressBar(
              'Yağ',
              _dailySummary.totalFat,
              _dailySummary.targetFat,
              'g',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroProgressBar(
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

  Widget _buildMealTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Günlük Öğünler',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ..._dailySummary.foods.map((food) => _buildMealTimelineItem(food)),
      ],
    );
  }

  Widget _buildMealTimelineItem(FoodItem food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restaurant, color: AppTheme.primaryColor),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${DateFormat('HH:mm').format(food.consumedAt)} • ${food.nutritionInfo.calories.toInt()} kcal',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientInfo(
                      'Protein',
                      '${food.nutritionInfo.protein.toStringAsFixed(1)}g',
                    ),
                    _buildNutrientInfo(
                      'Karb',
                      '${food.nutritionInfo.carbs.toStringAsFixed(1)}g',
                    ),
                    _buildNutrientInfo(
                      'Yağ',
                      '${food.nutritionInfo.fat.toStringAsFixed(1)}g',
                    ),
                    _buildNutrientInfo(
                      'Lif',
                      '${food.nutritionInfo.fiber.toStringAsFixed(1)}g',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildVitaminCard(),
          const SizedBox(height: 20),
          _buildMineralCard(),
        ],
      ),
    );
  }

  Widget _buildVitaminCard() {
    final vitamins = _dailySummary.totalVitamins;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vitaminler',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _buildNutrientDetailRow('Vitamin A', vitamins['A'] ?? 0, 900, 'μg'),
            _buildNutrientDetailRow(
              'Vitamin B12',
              vitamins['B12'] ?? 0,
              2.4,
              'μg',
            ),
            _buildNutrientDetailRow('Vitamin C', vitamins['C'] ?? 0, 90, 'mg'),
            _buildNutrientDetailRow('Vitamin D', vitamins['D'] ?? 0, 20, 'μg'),
          ],
        ),
      ),
    );
  }

  Widget _buildMineralCard() {
    final minerals = _dailySummary.totalMinerals;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mineraller',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _buildNutrientDetailRow(
              'Kalsiyum',
              minerals['Kalsiyum'] ?? 0,
              1000,
              'mg',
            ),
            _buildNutrientDetailRow('Demir', minerals['Demir'] ?? 0, 18, 'mg'),
            _buildNutrientDetailRow(
              'Fosfor',
              minerals['Fosfor'] ?? 0,
              700,
              'mg',
            ),
            _buildNutrientDetailRow(
              'Potasyum',
              minerals['Potasyum'] ?? 0,
              3500,
              'mg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientDetailRow(
    String name,
    double current,
    double daily,
    String unit,
  ) {
    final percentage = ((current / daily) * 100).clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                color: _getPercentageColor(
                  percentage.toDouble(),
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '%${percentage.toInt()}',
                style: TextStyle(
                  fontSize: 12,
                  color: _getPercentageColor(percentage.toDouble()),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage < 50) return Colors.red;
    if (percentage < 80) return Colors.orange;
    return AppTheme.primaryColor;
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPieChart(),
          const SizedBox(height: 30),
          _buildWeeklyChart(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Makro Besin Dağılımı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: _dailySummary.totalProtein,
                      title:
                          'Protein\n${(_dailySummary.totalProtein * 4 / _dailySummary.totalCalories * 100).toStringAsFixed(0)}%',
                      color: Colors.blue,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: _dailySummary.totalCarbs,
                      title:
                          'Karbonhidrat\n${(_dailySummary.totalCarbs * 4 / _dailySummary.totalCalories * 100).toStringAsFixed(0)}%',
                      color: Colors.orange,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: _dailySummary.totalFat,
                      title:
                          'Yağ\n${(_dailySummary.totalFat * 9 / _dailySummary.totalCalories * 100).toStringAsFixed(0)}%',
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
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Haftalık Kalori Takibi',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 2500,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Pzt',
                            'Sal',
                            'Çar',
                            'Per',
                            'Cum',
                            'Cmt',
                            'Paz',
                          ];
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 500,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(0, 1800),
                    _buildBarGroup(1, 2100),
                    _buildBarGroup(2, 1950),
                    _buildBarGroup(3, 2200),
                    _buildBarGroup(4, 1750),
                    _buildBarGroup(5, 2000),
                    _buildBarGroup(6, 1900),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y < 2000 ? AppTheme.primaryColor : AppTheme.warningColor,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}
