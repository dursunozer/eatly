import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../../core/theme/app_theme.dart';
import 'onboarding_viewmodel.dart';

class OnboardingView extends StackedView<OnboardingViewModel> {
  const OnboardingView({super.key});

  @override
  Widget builder(BuildContext context, OnboardingViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // İlerleme göstergesi
            _buildProgressIndicator(viewModel),
            
            // Sayfa içeriği
            Expanded(
              child: PageView(
                controller: viewModel.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: viewModel.onPageChanged,
                children: [
                  _GoalSelectionPage(viewModel: viewModel),
                  _GenderSelectionPage(viewModel: viewModel),
                  _BodyInfoPage(viewModel: viewModel),
                  _ActivityLevelPage(viewModel: viewModel),
                  _SummaryPage(viewModel: viewModel),
                  _UserInfoPage(viewModel: viewModel),
                  _AuthMethodPage(viewModel: viewModel),
                ],
              ),
            ),
            
            // Navigasyon butonları
            _buildNavigationButtons(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(OnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(viewModel.totalPages, (index) {
          final isActive = index <= viewModel.currentPage;
          final isCurrent = index == viewModel.currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: isCurrent ? 8 : 6,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, OnboardingViewModel viewModel) {
    final isAuthPage = viewModel.currentPage == viewModel.totalPages - 1;
    final isFirstPage = viewModel.currentPage == 0;

    // Hata mesajını göster
    if (viewModel.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.modelError.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      });
    }

    // Giriş yöntemi sayfasında butonları gizle (sayfa içinde gösterilecek)
    if (isAuthPage) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (!isFirstPage)
            Expanded(
              child: OutlinedButton(
                onPressed: viewModel.previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Geri'),
              ),
            ),
          if (!isFirstPage) const SizedBox(width: 16),
          Expanded(
            flex: isFirstPage ? 1 : 1,
            child: ElevatedButton(
              onPressed: viewModel.canProceed() ? viewModel.nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: viewModel.isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Devam',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  OnboardingViewModel viewModelBuilder(BuildContext context) => OnboardingViewModel();
}

// Sayfa 1: Hedef Seçimi
class _GoalSelectionPage extends StatelessWidget {
  final OnboardingViewModel viewModel;
  const _GoalSelectionPage({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Hoş Geldin! 👋',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hedefin ne? Sana en uygun beslenme planını oluşturalım.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ...viewModel.goalOptions.map((option) => _GoalCard(
            option: option,
            isSelected: viewModel.selectedGoal == option.id,
            onTap: () => viewModel.setGoal(option.id),
          )),
          const SizedBox(height: 24),
          // Zaten hesabım var linki - altta ortalı
          Center(
            child: TextButton(
              onPressed: () => viewModel.goToLogin(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Zaten hesabın var mı? ',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Giriş Yap',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? option.color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? option.color : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: option.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(option.icon, color: option.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? option.color : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: option.color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sayfa 2: Cinsiyet Seçimi
class _GenderSelectionPage extends StatelessWidget {
  final OnboardingViewModel viewModel;
  const _GenderSelectionPage({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Cinsiyetin nedir?',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Metabolizma hızını doğru hesaplamak için cinsiyetini bilmemiz gerekiyor.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  title: 'Erkek',
                  icon: Icons.male,
                  isSelected: viewModel.selectedGender == 'Erkek',
                  color: Colors.blue,
                  onTap: () => viewModel.setGender('Erkek'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GenderCard(
                  title: 'Kadın',
                  icon: Icons.female,
                  isSelected: viewModel.selectedGender == 'Kadın',
                  color: Colors.pink,
                  onTap: () => viewModel.setGender('Kadın'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GenderCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : AppTheme.textPrimary,
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

// Sayfa 3: Fiziksel Bilgiler
class _BodyInfoPage extends StatefulWidget {
  final OnboardingViewModel viewModel;
  const _BodyInfoPage({required this.viewModel});

  @override
  State<_BodyInfoPage> createState() => _BodyInfoPageState();
}

class _BodyInfoPageState extends State<_BodyInfoPage> {
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.viewModel.age.toString());
    _weightController = TextEditingController(text: widget.viewModel.weight.toInt().toString());
    _heightController = TextEditingController(text: widget.viewModel.height.toInt().toString());
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Fiziksel Bilgilerin',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Günlük kalori ihtiyacını hesaplamak için bu bilgilere ihtiyacımız var.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Yaş
          _InfoInputCard(
            title: 'Yaş',
            subtitle: 'yıl',
            icon: Icons.cake,
            color: Colors.orange,
            controller: _ageController,
            onChanged: (value) {
              final intValue = int.tryParse(value) ?? 0;
              widget.viewModel.setAge(intValue);
            },
          ),
          const SizedBox(height: 16),
          
          // Kilo
          _InfoInputCard(
            title: 'Kilo',
            subtitle: 'kg',
            icon: Icons.monitor_weight,
            color: Colors.blue,
            controller: _weightController,
            onChanged: (value) {
              final doubleValue = double.tryParse(value) ?? 0;
              widget.viewModel.setWeight(doubleValue);
            },
          ),
          const SizedBox(height: 16),
          
          // Boy
          _InfoInputCard(
            title: 'Boy',
            subtitle: 'cm',
            icon: Icons.height,
            color: Colors.green,
            controller: _heightController,
            onChanged: (value) {
              final doubleValue = double.tryParse(value) ?? 0;
              widget.viewModel.setHeight(doubleValue);
            },
          ),
          
          const SizedBox(height: 24),
          
          // BKİ gösterimi
          _BmiPreview(
            height: widget.viewModel.height,
            weight: widget.viewModel.weight,
          ),
        ],
      ),
    );
  }
}

class _InfoInputCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final TextEditingController controller;
  final Function(String) onChanged;

  const _InfoInputCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: onChanged,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
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
}

class _BmiPreview extends StatelessWidget {
  final double height;
  final double weight;

  const _BmiPreview({required this.height, required this.weight});

  @override
  Widget build(BuildContext context) {
    double? bmi;
    String category = '';
    Color categoryColor = Colors.grey;

    if (height > 0 && weight > 0) {
      final m = height / 100.0;
      bmi = weight / (m * m);
      
      if (bmi < 18.5) {
        category = 'Zayıf';
        categoryColor = Colors.blue;
      } else if (bmi < 25) {
        category = 'Normal';
        categoryColor = Colors.green;
      } else if (bmi < 30) {
        category = 'Fazla Kilolu';
        categoryColor = Colors.orange;
      } else {
        category = 'Obez';
        categoryColor = Colors.red;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vücut Kitle İndeksi (BKİ)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bmi != null ? bmi.toStringAsFixed(1) : '-',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Sayfa 4: Aktivite Seviyesi
class _ActivityLevelPage extends StatelessWidget {
  final OnboardingViewModel viewModel;
  const _ActivityLevelPage({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Aktivite Seviyen',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Haftalık egzersiz rutinini seç.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ...viewModel.activityOptions.map((option) => _ActivityCard(
            option: option,
            isSelected: viewModel.selectedActivityLevel == option.id,
            onTap: () => viewModel.setActivityLevel(option.id),
          )),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    option.icon,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        option.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sayfa 5: Özet ve Hesaplama
class _SummaryPage extends StatelessWidget {
  final OnboardingViewModel viewModel;
  const _SummaryPage({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final targets = viewModel.calculatedTargets;
    final goal = viewModel.goalOptions.firstWhere(
      (g) => g.id == viewModel.selectedGoal,
      orElse: () => viewModel.goalOptions.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Hazırsın! 🎉',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bilgilerine göre kişiselleştirilmiş hedeflerini hesapladık.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Hedef kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [goal.color, goal.color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(goal.icon, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hedefin',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        goal.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Günlük hedefler
          const Text(
            'Günlük Hedefler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          if (targets != null) ...[
            _TargetCard(
              title: 'Kalori',
              value: '${targets.targetCalories.toInt()}',
              unit: 'kcal',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TargetCard(
                    title: 'Protein',
                    value: '${targets.targetProtein.toInt()}',
                    unit: 'g',
                    icon: Icons.egg,
                    color: Colors.red,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TargetCard(
                    title: 'Karbonhidrat',
                    value: '${targets.targetCarbs.toInt()}',
                    unit: 'g',
                    icon: Icons.grain,
                    color: Colors.amber,
                    compact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TargetCard(
              title: 'Yağ',
              value: '${targets.targetFat.toInt()}',
              unit: 'g',
              icon: Icons.water_drop,
              color: Colors.purple,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Bilgi notu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bu hedefler profil ayarlarından istediğin zaman güncellenebilir.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool compact;

  const _TargetCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
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
          Container(
            padding: EdgeInsets.all(compact ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: compact ? 20 : 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: compact ? 20 : 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontSize: compact ? 12 : 14,
                          color: AppTheme.textSecondary,
                        ),
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
}

// Sayfa 6: Kullanıcı Bilgileri (İsim)
class _UserInfoPage extends StatefulWidget {
  final OnboardingViewModel viewModel;
  const _UserInfoPage({required this.viewModel});

  @override
  State<_UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<_UserInfoPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.viewModel.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          
          // Avatar/Icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          Text(
            'Sana nasıl hitap edelim?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Adını girerek başlayalım.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // İsim girişi
          Container(
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
            child: TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Adın Soyadın',
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZğüşöçıİĞÜŞÖÇ ]")),
              ],
              onChanged: (value) {
                widget.viewModel.setDisplayName(value);
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Bilgi notu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bilgilerin güvende. Gizlilik politikamıza uygun olarak saklanır.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sayfa 7: Giriş Yöntemi Seçimi
class _AuthMethodPage extends StatefulWidget {
  final OnboardingViewModel viewModel;
  const _AuthMethodPage({required this.viewModel});

  @override
  State<_AuthMethodPage> createState() => _AuthMethodPageState();
}

class _AuthMethodPageState extends State<_AuthMethodPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.viewModel.email);
    _passwordController = TextEditingController(text: widget.viewModel.password);
    _passwordConfirmController = TextEditingController(text: widget.viewModel.passwordConfirm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // E-posta formu gösteriliyorsa
    if (widget.viewModel.showEmailForm) {
      return _buildEmailForm(context);
    }
    
    return _buildAuthMethodSelection(context);
  }

  Widget _buildAuthMethodSelection(BuildContext context) {
    final canProceed = widget.viewModel.acceptKvkk && widget.viewModel.acceptHealth;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          Text(
            'Son adım! 🚀',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hesabını oluşturmak için onayları ver ve bir yöntem seç.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // KVKK ve Sağlık Verisi Onayları
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildAuthConsentCheckbox(
                  value: widget.viewModel.acceptKvkk,
                  onChanged: (value) => widget.viewModel.setKvkkAcceptance(value ?? false),
                  title: 'KVKK ve Gizlilik Politikasını kabul ediyorum',
                  isRequired: true,
                ),
                const SizedBox(height: 12),
                _buildAuthConsentCheckbox(
                  value: widget.viewModel.acceptHealth,
                  onChanged: (value) => widget.viewModel.setHealthAcceptance(value ?? false),
                  title: 'Sağlık verilerimin işlenmesine açık rıza veriyorum',
                  isRequired: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Google ile devam et
          Opacity(
            opacity: canProceed ? 1.0 : 0.5,
            child: _GoogleAuthButton(
              onTap: (canProceed && !widget.viewModel.isBusy) 
                  ? () => widget.viewModel.signUpWithGoogle() 
                  : null,
              isLoading: widget.viewModel.isBusy,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // E-posta ile devam et
          Opacity(
            opacity: canProceed ? 1.0 : 0.5,
            child: _AuthMethodButton(
              icon: Icons.email_outlined,
              iconColor: AppTheme.primaryColor,
              title: 'E-posta ile devam et',
              subtitle: 'E-posta ve şifre ile kayıt ol',
              onTap: canProceed ? () => widget.viewModel.showEmailFormView() : null,
            ),
          ),
          
          if (!canProceed) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Devam etmek için yukarıdaki onayları verin',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Geri butonu
          Center(
            child: TextButton.icon(
              onPressed: widget.viewModel.previousPage,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Geri Dön'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAuthConsentCheckbox({
    required bool value,
    required void Function(bool?)? onChanged,
    required String title,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: title),
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Geri butonu
          IconButton(
            onPressed: widget.viewModel.hideEmailForm,
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'E-posta ile Kayıt Ol',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'E-posta adresini ve şifreni gir.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // E-posta
          _buildTextField(
            controller: _emailController,
            label: 'E-posta',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: widget.viewModel.setEmail,
          ),
          
          const SizedBox(height: 16),
          
          // Şifre
          _buildTextField(
            controller: _passwordController,
            label: 'Şifre',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            onChanged: widget.viewModel.setPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondary,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          
          const SizedBox(height: 8),
          Text(
            'En az 8 karakter, 1 büyük harf ve 1 özel karakter',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Şifre Tekrar
          _buildTextField(
            controller: _passwordConfirmController,
            label: 'Şifre Tekrar',
            icon: Icons.lock_outline,
            obscureText: _obscurePasswordConfirm,
            onChanged: widget.viewModel.setPasswordConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePasswordConfirm ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondary,
              ),
              onPressed: () => setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // KVKK ve Sağlık Verisi Onayları
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildConsentCheckbox(
                  value: widget.viewModel.acceptKvkk,
                  onChanged: (value) => widget.viewModel.setKvkkAcceptance(value ?? false),
                  title: 'KVKK ve Gizlilik Politikasını kabul ediyorum',
                  isRequired: true,
                ),
                const SizedBox(height: 12),
                _buildConsentCheckbox(
                  value: widget.viewModel.acceptHealth,
                  onChanged: (value) => widget.viewModel.setHealthAcceptance(value ?? false),
                  title: 'Sağlık verilerimin işlenmesine açık rıza veriyorum',
                  isRequired: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Kayıt Ol butonu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (widget.viewModel.canSubmitEmailForm && !widget.viewModel.isBusy) 
                  ? () => widget.viewModel.signUpWithEmail() 
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: widget.viewModel.isBusy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Hesabımı Oluştur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required void Function(bool?)? onChanged,
    required String title,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: title),
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    required Function(String) onChanged,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class _AuthMethodButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  const _AuthMethodButton({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: iconColor,
                        ),
                      )
                    : Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Google ile Giriş Butonu (Özel Tasarım)
class _GoogleAuthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const _GoogleAuthButton({
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Google Logo
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _buildGoogleLogo(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Google',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          ' ile devam et',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hızlı ve güvenli giriş',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Google Logo (CustomPaint ile çizim)
  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double centerX = w / 2;
    final double centerY = h / 2;
    final double radius = w * 0.42;
    final double strokeWidth = w * 0.18;

    // Google renkleri
    const blueColor = Color(0xFF4285F4);
    const greenColor = Color(0xFF34A853);
    const yellowColor = Color(0xFFFBBC05);
    const redColor = Color(0xFFEA4335);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Mavi bölüm (sağ üst) - 0 ile -90 derece arası
    paint.color = blueColor;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -0.4, // ~-23 derece
      -1.2, // ~-69 derece
      false,
      paint,
    );

    // Yeşil bölüm (sağ alt) - 0 ile 90 derece arası
    paint.color = greenColor;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      0.4, // ~23 derece
      1.15, // ~66 derece
      false,
      paint,
    );

    // Sarı bölüm (sol alt) - 90 ile 180 derece arası
    paint.color = yellowColor;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      1.55, // ~89 derece
      1.0, // ~57 derece
      false,
      paint,
    );

    // Kırmızı bölüm (sol üst) - 180 ile 270 derece arası
    paint.color = redColor;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      2.55, // ~146 derece
      1.2, // ~69 derece
      false,
      paint,
    );

    // Mavi yatay çizgi (Google G'nin ortası)
    paint.color = blueColor;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX + radius + strokeWidth * 0.3, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

