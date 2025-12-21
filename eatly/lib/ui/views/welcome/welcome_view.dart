import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'welcome_viewmodel.dart';

class WelcomeView extends StackedView<WelcomeViewModel> {
  const WelcomeView({super.key});

  @override
  Widget builder(BuildContext context, WelcomeViewModel viewModel, Widget? child) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A5F2A),
              Color(0xFF2ECC71),
              Color(0xFF27AE60),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo ve İsim
              _buildLogoSection(),
              
              const Spacer(flex: 1),
              
              // Özellikler
              _buildFeaturesSection(),
              
              const Spacer(flex: 2),
              
              // Butonlar
              _buildButtonsSection(context, viewModel),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            // easeOutBack 0-1 aralığının dışına çıkabilir, clamp ile sınırlıyoruz
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // Logo Container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🥗',
                style: TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Uygulama İsmi
          const Text(
            'Eatly',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          
          // Slogan
          Text(
            'Sağlıklı Beslenmenin Akıllı Yolu',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      _FeatureItem(
        icon: Icons.camera_alt_rounded,
        text: 'Fotoğraf çek, besin değerlerini öğren',
        delay: 400,
      ),
      _FeatureItem(
        icon: Icons.track_changes_rounded,
        text: 'Günlük kalori ve makro takibi',
        delay: 600,
      ),
      _FeatureItem(
        icon: Icons.trending_up_rounded,
        text: 'Kişiselleştirilmiş hedefler',
        delay: 800,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: features.map((feature) => _buildFeatureRow(feature)).toList(),
      ),
    );
  }

  Widget _buildFeatureRow(_FeatureItem feature) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature.icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                feature.text,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsSection(BuildContext context, WelcomeViewModel viewModel) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            // Başla Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: viewModel.isBusy ? null : () => viewModel.startOnboarding(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2ECC71),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: viewModel.isBusy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF2ECC71),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Başla',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Giriş Yap Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: viewModel.navigateToLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Zaten hesabım var',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Gizlilik Notu
            Text(
              'Devam ederek Gizlilik Politikası\'nı kabul etmiş olursunuz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  WelcomeViewModel viewModelBuilder(BuildContext context) => WelcomeViewModel();
}

class _FeatureItem {
  final IconData icon;
  final String text;
  final int delay;

  _FeatureItem({
    required this.icon,
    required this.text,
    required this.delay,
  });
}


