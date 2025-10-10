import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/models/daily_summary.dart';
import 'meal_history_viewmodel.dart';

class MealHistoryView extends StatelessWidget {
  const MealHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MealHistoryViewModel>.reactive(
      viewModelBuilder: () => MealHistoryViewModel()..loadMeals(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text('Beslenme Geçmişi', style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
          ),
          body: model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                      child: Column(
                        children: [
                      // Takvim
                      _buildCalendar(context, model),
                      
                      const SizedBox(height: 8),
                      
                      // Nutrition Facts Kartı
                      if (model.dailySummary != null)
                        _buildNutritionFactsCard(context, model.dailySummary!)
                      else
                        _buildEmptyState(),
                    ],
                  ),
                    ),
        );
      },
    );
  }

  Widget _buildCalendar(BuildContext context, MealHistoryViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now(),
        focusedDay: model.focusedDay,
        selectedDayPredicate: (day) => isSameDay(model.selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!selectedDay.isAfter(DateTime.now())) {
            model.onDaySelected(selectedDay, focusedDay);
          }
        },
        calendarFormat: CalendarFormat.week,
        availableCalendarFormats: const {
          CalendarFormat.week: 'Hafta',
        },
        locale: 'tr_TR',
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF2E7D32)),
          rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFF2E7D32)),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: const TextStyle(fontSize: 14),
          weekendTextStyle: const TextStyle(fontSize: 14, color: Colors.red),
          outsideDaysVisible: false,
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          weekendStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildNutritionFactsCard(BuildContext context, DailySummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
          // Kalori Kartı (Öne Çıkan)
          Container(
                  width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Toplam Kalori',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${summary.totalCalories.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'kcal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
              ),
            const SizedBox(height: 12),
                _buildProgressBar(
                  summary.totalCalories / summary.targetCalories,
                  Colors.white,
            ),
            const SizedBox(height: 8),
                Text(
                  'Hedef: ${summary.targetCalories.toInt()} kcal',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Makro Besinler Listesi
          _buildMacroNutrientCard(
            'Protein',
            summary.totalProtein,
            'g',
            summary.targetProtein,
            summary.totalProtein / summary.targetProtein,
            const Color(0xFFE91E63),
            Icons.egg_alt_rounded,
          ),
          
          const SizedBox(height: 12),
          
          _buildMacroNutrientCard(
            'Karbonhidrat',
            summary.totalCarbs,
            'g',
            summary.targetCarbs,
            summary.totalCarbs / summary.targetCarbs,
            const Color(0xFFFF9800),
            Icons.grain_rounded,
          ),
          
          const SizedBox(height: 12),
          
          _buildMacroNutrientCard(
            'Yağ',
            summary.totalFat,
            'g',
            summary.targetFat,
            summary.totalFat / summary.targetFat,
            const Color(0xFF9C27B0),
            Icons.water_drop_rounded,
          ),
          
          // Fiber (eğer varsa)
          if (summary.totalFiber > 0) ...[
            const SizedBox(height: 12),
            _buildMacroNutrientCard(
              'Lif',
              summary.totalFiber,
              'g',
              25,
              summary.totalFiber / 25,
              const Color(0xFF795548),
              Icons.eco_rounded,
            ),
          ],
          
          // Detaylı Besin Değerleri (sadece varsa göster)
          if (summary.totalSaturatedFat > 0 || summary.totalTransFat > 0 || 
              summary.totalPolyunsaturatedFat > 0 || summary.totalMonounsaturatedFat > 0 ||
              summary.totalCholesterol > 0 || summary.totalSodium > 0 || summary.totalSugars > 0) ...[
            const SizedBox(height: 24),
            _buildDetailedNutrientsSection(summary),
          ],
          
          // Vitaminler ve Mineraller
          if (summary.totalVitamins.isNotEmpty || summary.totalMinerals.isNotEmpty || 
              summary.totalVitaminA > 0 || summary.totalVitaminC > 0 || summary.totalVitaminD > 0 ||
              summary.totalCalcium > 0 || summary.totalIron > 0 || summary.totalPotassium > 0) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vitaminler
                  if (summary.totalVitaminA > 0 || summary.totalVitaminC > 0 || 
                      summary.totalVitaminD > 0 || summary.totalVitamins.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            color: Color(0xFFFF9800),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Vitaminler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (summary.totalVitaminA > 0) _buildMicronutrientChip('Vitamin A', summary.totalVitaminA, 'mcg'),
                        if (summary.totalVitaminC > 0) _buildMicronutrientChip('Vitamin C', summary.totalVitaminC, 'mg'),
                        if (summary.totalVitaminD > 0) _buildMicronutrientChip('Vitamin D', summary.totalVitaminD, 'mcg'),
                        ...summary.totalVitamins.entries.map((entry) {
                          return _buildMicronutrientChip(entry.key, entry.value, 'mg');
                        }).toList(),
                      ],
                    ),
                    if (summary.totalMinerals.isNotEmpty) const SizedBox(height: 20),
                  ],
                  
                  // Mineraller
                  if (summary.totalCalcium > 0 || summary.totalIron > 0 || 
                      summary.totalPotassium > 0 || summary.totalMinerals.isNotEmpty) ...[
                    Row(
                      children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.landscape_rounded,
                            color: Color(0xFF2196F3),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Mineraller',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
              ),
          ],
        ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (summary.totalCalcium > 0) _buildMicronutrientChip('Kalsiyum', summary.totalCalcium, 'mg'),
                        if (summary.totalIron > 0) _buildMicronutrientChip('Demir', summary.totalIron, 'mg'),
                        if (summary.totalPotassium > 0) _buildMicronutrientChip('Potasyum', summary.totalPotassium, 'mg'),
                        ...summary.totalMinerals.entries.map((entry) {
                          return _buildMicronutrientChip(entry.key, entry.value, 'mg');
                        }).toList(),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMacroNutrientCard(
    String label,
    double value,
    String unit,
    double target,
    double progress,
    Color color,
    IconData icon,
  ) {
    final percentage = (progress * 100).clamp(0, 999).toInt();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
        padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
              children: [
                        Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          unit,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: color.withOpacity(0.7),
                          ),
                  ),
              ],
            ),
                  ],
                ),
                
              const SizedBox(height: 8),
                
                // Progress bar
                _buildProgressBar(progress, color),
                
                const SizedBox(height: 6),
                
                // Percentage and target
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text(
                      '$percentage% hedefe ulaşıldı',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Hedef: ${target.toStringAsFixed(0)}$unit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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

  Widget _buildProgressBar(double progress, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: color.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 8,
      ),
    );
  }

  Widget _buildDetailedNutrientsSection(DailySummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detaylı Besin Değerleri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Yağ Detayları
          if (summary.totalSaturatedFat > 0 || summary.totalTransFat > 0 || 
              summary.totalPolyunsaturatedFat > 0 || summary.totalMonounsaturatedFat > 0) ...[
            _buildDetailRow('Doymuş Yağ', summary.totalSaturatedFat, 'g'),
            if (summary.totalTransFat > 0) _buildDetailRow('Trans Yağ', summary.totalTransFat, 'g'),
            if (summary.totalPolyunsaturatedFat > 0) _buildDetailRow('Çoklu Doymamış Yağ', summary.totalPolyunsaturatedFat, 'g'),
            if (summary.totalMonounsaturatedFat > 0) _buildDetailRow('Tekli Doymamış Yağ', summary.totalMonounsaturatedFat, 'g'),
            const Divider(height: 24),
          ],
          
          // Kolesterol ve Sodyum
          if (summary.totalCholesterol > 0) 
            _buildDetailRow('Kolesterol', summary.totalCholesterol, 'mg'),
          if (summary.totalSodium > 0) 
            _buildDetailRow('Sodyum', summary.totalSodium, 'mg'),
          
          // Şeker
          if (summary.totalSugars > 0) ...[
            const Divider(height: 24),
            _buildDetailRow('Şeker', summary.totalSugars, 'g'),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
        ),
        Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicronutrientChip(String name, double value, String unit) {
    // Vitamin/mineral isimlendirmelerini güzelleştir
    String displayName = name;
    
    // Ortak vitamin/mineral isimleri
    if (name.toLowerCase() == 'calcium' || name.toLowerCase() == 'kalsiyum') {
      displayName = 'Kalsiyum';
    } else if (name.toLowerCase() == 'iron' || name.toLowerCase() == 'demir') {
      displayName = 'Demir';
    } else if (name.toLowerCase() == 'potassium' || name.toLowerCase() == 'potasyum') {
      displayName = 'Potasyum';
    } else if (name.toLowerCase() == 'sodium' || name.toLowerCase() == 'sodyum') {
      displayName = 'Sodyum';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Bu tarihte henüz öğün kaydı bulunmuyor',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
