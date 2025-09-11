import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/food_item.dart';
import '../../../core/services/photo_service.dart';
import '../../../core/services/powersync_service.dart';
import 'dart:io';
import 'home_viewmodel.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (m) => m.init(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          //appBar: AppBar(title: const Text('Eatly')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(model),
                const SizedBox(height: 20),
                _buildDailySummaryCard(context, model),
                const SizedBox(height: 20),
                _buildRecentMeals(model),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(HomeViewModel model) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.greeting,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            model.displayName ?? model.formattedDate,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, HomeViewModel model) {
    final s = model.todaySummary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Günlük Özet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: CircularPercentIndicator(
                radius: 100,
                lineWidth: 12,
                percent: s.caloriesProgress.clamp(0, 1),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${s.totalCalories.toInt()}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '/ ${s.targetCalories.toInt()} kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                progressColor: AppTheme.primaryColor,
                backgroundColor: Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroInfo(
                  'Protein',
                  s.totalProtein,
                  s.targetProtein,
                  Colors.blue,
                ),
                _buildMacroInfo(
                  'Karbonhidrat',
                  s.totalCarbs,
                  s.targetCarbs,
                  Colors.orange,
                ),
                _buildMacroInfo('Yağ', s.totalFat, s.targetFat, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(
    String label,
    double current,
    double target,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          '${current.toInt()}g',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Text(
          '/ hedef',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRecentMeals(HomeViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Son Öğünler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<String>>(
          future: _loadCombinedPhotos(),
          builder: (context, snapshot) {
            final photos = snapshot.data ?? <String>[];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (photos.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Henüz öğün eklemediniz',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final url = photos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: url.startsWith('file://')
                        ? Image.file(
                            File(url.replaceFirst('file://', '')),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<List<String>> _loadCombinedPhotos() async {
    // 1) Offline kuyruktan bugünkü senkronlanmamış dosyaları al (en yeni üste)
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    List<Map<String, Object?>> local = <Map<String, Object?>>[];
    try {
      final rows = await AppPowerSync.instance.db.getAll(
        'select local_path, taken_at from local_photos where is_synced = 0 and taken_at >= ? order by taken_at desc',
        [start.toIso8601String()],
      );
      local = rows
          .map(
            (r) => {
              'local_path': r['local_path'] as String,
              'taken_at': r['taken_at'] as String,
            },
          )
          .toList();
    } catch (_) {
      // Web veya DB hazır değilse local list boş kalsın
    }

    // 2) Supabase'ten bugünkü senkronlanmış URL'ler
    final remote = await PhotoService.fetchTodayPhotoUrls();

    // 3) Birleştir: önce local (file://), sonra remote
    final combined = <String>[
      ...local.map((e) => 'file://${e['local_path']}'),
      ...remote,
    ];
    return combined;
  }

  Widget _buildFoodItem(FoodItem food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
          ),
          child: const Icon(Icons.fastfood, color: AppTheme.primaryColor),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${food.portion.toInt()}g • ${food.nutritionInfo.calories.toInt()} kcal',
        ),
      ),
    );
  }
}
