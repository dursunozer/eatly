import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import 'home_viewmodel.dart';
import '../../../core/models/meal_photo.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(viewModel),
            const SizedBox(height: 20),
            _buildDailySummaryCard(context, viewModel),
            const SizedBox(height: 20),
            _buildRecentMeals(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(HomeViewModel viewModel) {
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
            viewModel.greeting,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.displayName ?? viewModel.formattedDate,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, HomeViewModel viewModel) {
    final s = viewModel.todaySummary;
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

  Widget _buildRecentMeals(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Öğünler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 0),
        FutureBuilder(
          future: viewModel.todayMealPhotosFuture,
              builder: (context, snapshot) {
                final items = snapshot.data ?? <MealPhoto>[];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (items.isEmpty) {
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
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = items[index];
                return _SwipeableRow(
                  photo: p,
                  onDelete: () => viewModel.deleteMealPhoto(p.id),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    viewModel.init();
    // Timer'ı başlatmıyoruz - sadece yeni fotoğraf eklendiğinde çalışacak
  }
}

class _SwipeableRow extends StatefulWidget {
  final MealPhoto photo;
  final VoidCallback onDelete;

  const _SwipeableRow({required this.photo, required this.onDelete});

  @override
  State<_SwipeableRow> createState() => _SwipeableRowState();
}

class _SwipeableRowState extends State<_SwipeableRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _armedToDelete = false; // İlk sola kaydırmada kolu kur, ikincide sil

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.photo.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(armed: _armedToDelete),
      confirmDismiss: (direction) async {
        if (!_armedToDelete) {
          setState(() => _armedToDelete = true);
          await _controller.forward();
          // İlk kaydırmada sadece silme arayüzünü göster
          return false;
        }
        // İkinci kaydırmada sil
        widget.onDelete();
        return true;
      },
      child: _MealRow(photo: widget.photo),
    );
  }

  Widget _buildDeleteBackground({required bool armed}) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            armed ? Colors.red.shade600 : Colors.red.shade400,
            armed ? Colors.red.shade700 : Colors.red.shade500,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: armed ? 1.1 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(armed ? Icons.delete_forever : Icons.delete_sweep, color: Colors.white, size: 26),
                const SizedBox(height: 4),
                Text(
                  armed ? 'Tekrar çek silinsin' : 'Sola çek',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final MealPhoto photo;
  const _MealRow({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 80, height: 80, child: _buildImage()),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photo.isAnalyzing)
                  Text(
                    photo.isWaitingNetwork
                        ? 'İnternet gelince analiz yapılacak...'
                        : 'Fotoğraf analiz ediliyor...',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  )
                else if (photo.detectedItems.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Besin isimleri
                      Wrap(
                    spacing: 6,
                        runSpacing: 4,
                        children: photo.detectedItems
                            .map((item) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['name']?.toString() ?? '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                            ))
                        .toList(),
                      ),
                      const SizedBox(height: 12),
                      // Toplam besin değerleri (tüm öğeleri kullan)
                      _buildTotalNutrition(photo.detectedItems),
                    ],
                  )
                else
                  const Text(
                    'Öğe bulunamadı',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalNutrition(List<Map<String, dynamic>> items) {
    // Tüm besinlerin değerlerini topla
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalWeight = 0;

    for (final item in items) {
      final nutrition = item['nutrition'] as Map<String, dynamic>?;
      if (nutrition != null) {
        totalCalories += (nutrition['calories'] as num?)?.toDouble() ?? 0;
        totalProtein += (nutrition['protein'] as num?)?.toDouble() ?? 0;
        totalCarbs += (nutrition['carbohydrate'] as num?)?.toDouble() ?? 
                     (nutrition['carbs'] as num?)?.toDouble() ?? 0;
        totalFat += (nutrition['fat'] as num?)?.toDouble() ?? 0;
        // Tahmini ağırlık hesabı (kalori/4 yaklaşımı)
        totalWeight += ((nutrition['calories'] as num?)?.toDouble() ?? 0) / 4;
      }
    }

    if (totalCalories == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Besin değerleri hesaplanıyor...',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Toplam Besin Değerleri',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  '${totalWeight.toInt()}g',
                  'Ağırlık',
                  Icons.scale,
                  Colors.grey,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  '${totalCalories.toInt()}',
                  'Kalori',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  '${totalProtein.toInt()}g',
                  'Protein',
                  Icons.fitness_center,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  '${totalCarbs.toInt()}g',
                  'Karbonhidrat',
                  Icons.grain,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  '${totalFat.toInt()}g',
                  'Yağ',
                  Icons.water_drop,
                  Colors.purple,
                ),
              ),
              const Expanded(child: SizedBox()), // Boş alan
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String value, String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Bilinmeyen';
    final confidence = (item['confidence'] as num?)?.toDouble() ?? 0.0;
    final nutrition = item['nutrition'] as Map<String, dynamic>?;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (confidence > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          if (nutrition != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildNutritionBadge(
                  '${nutrition['calories']?.toInt() ?? 0} kcal',
                  Colors.orange,
                  Icons.local_fire_department,
                ),
                _buildNutritionBadge(
                  'P: ${nutrition['protein']?.toInt() ?? 0}g',
                  Colors.blue,
                  Icons.fitness_center,
                ),
                _buildNutritionBadge(
                  'C: ${nutrition['carbohydrate']?.toInt() ?? nutrition['carbs']?.toInt() ?? 0}g',
                  Colors.green,
                  Icons.grain,
                ),
                _buildNutritionBadge(
                  'Y: ${nutrition['fat']?.toInt() ?? 0}g',
                  Colors.purple,
                  Icons.water_drop,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (photo.imageBytes != null) {
      return Image.memory(photo.imageBytes!, fit: BoxFit.cover);
    }
    if (photo.imagePath != null && photo.imagePath!.isNotEmpty) {
      final file = File(photo.imagePath!);
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Image.file hatası: $error');
          return Container(
            color: Colors.grey.shade200,
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.image, color: Colors.grey),
    );
  }
}
