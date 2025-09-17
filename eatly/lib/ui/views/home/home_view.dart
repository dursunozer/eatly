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
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    setState(() {
      _isDeleting = true;
    });
    
    await _animationController.forward();
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value == 0.0 ? 0.0 : 1.0 - (_scaleAnimation.value * 0.1),
          child: SlideTransition(
            position: _slideAnimation,
            child: Dismissible(
              key: Key(widget.photo.id),
              direction: DismissDirection.endToStart,
              background: _buildDeleteBackground(),
              confirmDismiss: (direction) async {
                _handleDelete();
                return false; // Dismissible'ın kendi animasyonunu engelle
              },
              child: _MealRow(photo: widget.photo),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400,
            Colors.red.shade600,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_sweep,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          const Text(
            'Sil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 72, height: 72, child: _buildImage()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photo.isAnalyzing)
                  const Text(
                    'Fotoğraf analiz ediliyor...',
                    style: TextStyle(color: AppTheme.textSecondary),
                  )
                else if (photo.detectedItems.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Besin isimleri
                  Wrap(
                        spacing: 4,
                        runSpacing: 2,
                    children: photo.detectedItems
                            .take(3)
                            .map((item) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['name']?.toString() ?? '-',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                            ))
                        .toList(),
                      ),
                      const SizedBox(height: 8),
                      // Toplam besin değerleri
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
      padding: const EdgeInsets.all(10),
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
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildCompactNutrition('${totalWeight.toInt()}g', 'Ağırlık', Colors.grey),
              _buildCompactNutrition('${totalCalories.toInt()}', 'Kalori', Colors.orange),
              _buildCompactNutrition('${totalProtein.toInt()}g', 'Protein', Colors.blue),
              _buildCompactNutrition('${totalCarbs.toInt()}g', 'Karb', Colors.green),
              _buildCompactNutrition('${totalFat.toInt()}g', 'Yağ', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNutrition(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Eski metotlar kaldırıldı - artık kompakt tasarım kullanılıyor

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
