import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/consent_service.dart';
import '../../../core/services/nutrition_calculator_service.dart';
import '../../../core/services/profile_service.dart';

class OnboardingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  final PageController pageController = PageController();

  // Mevcut sayfa
  int _currentPage = 0;
  int get currentPage => _currentPage;

  // Toplam sayfa sayısı (5 + kullanıcı bilgileri + giriş yöntemi)
  final int totalPages = 7;

  // Form verileri
  String? _selectedGoal;
  String? get selectedGoal => _selectedGoal;

  String _selectedGender = 'Erkek';
  String get selectedGender => _selectedGender;

  int _age = 25;
  int get age => _age;

  double _weight = 70;
  double get weight => _weight;

  double _height = 170;
  double get height => _height;

  String _selectedActivityLevel = NutritionCalculatorService.activityModeratelyActive;
  String get selectedActivityLevel => _selectedActivityLevel;

  // Kullanıcı bilgileri
  String _displayName = '';
  String get displayName => _displayName;
  
  // E-posta kayıt formu
  String _email = '';
  String get email => _email;
  
  String _password = '';
  String get password => _password;
  
  String _passwordConfirm = '';
  String get passwordConfirm => _passwordConfirm;
  
  // Giriş yöntemi seçimi
  bool _showEmailForm = false;
  bool get showEmailForm => _showEmailForm;

  // KVKK ve Sağlık Verisi Onayları
  bool _acceptKvkk = false;
  bool get acceptKvkk => _acceptKvkk;
  
  bool _acceptHealth = false;
  bool get acceptHealth => _acceptHealth;

  void setKvkkAcceptance(bool value) {
    _acceptKvkk = value;
    notifyListeners();
  }

  void setHealthAcceptance(bool value) {
    _acceptHealth = value;
    notifyListeners();
  }

  bool get canSubmitEmailForm => 
      _email.isNotEmpty && 
      _password.isNotEmpty && 
      _passwordConfirm.isNotEmpty &&
      _acceptKvkk && 
      _acceptHealth;

  // Hesaplanan değerler
  NutritionTargets? _calculatedTargets;
  NutritionTargets? get calculatedTargets => _calculatedTargets;

  // Hedef seçenekleri
  final List<GoalOption> goalOptions = [
    GoalOption(
      id: NutritionCalculatorService.goalLoseWeight,
      title: 'Kilo Vermek',
      subtitle: 'Sağlıklı bir şekilde kilo ver',
      icon: Icons.trending_down,
      color: Colors.orange,
    ),
    GoalOption(
      id: NutritionCalculatorService.goalGainWeight,
      title: 'Kilo Almak',
      subtitle: 'Sağlıklı bir şekilde kilo al',
      icon: Icons.trending_up,
      color: Colors.blue,
    ),
    GoalOption(
      id: NutritionCalculatorService.goalMaintain,
      title: 'Kilomu Korumak',
      subtitle: 'Mevcut kilonu koru',
      icon: Icons.balance,
      color: Colors.green,
    ),
    GoalOption(
      id: NutritionCalculatorService.goalBuildMuscle,
      title: 'Kas Kütlesi Kazanmak',
      subtitle: 'Kas yapısını geliştir',
      icon: Icons.fitness_center,
      color: Colors.purple,
    ),
  ];

  // Aktivite seviyeleri
  final List<ActivityOption> activityOptions = [
    ActivityOption(
      id: NutritionCalculatorService.activitySedentary,
      title: 'Hareketsiz',
      subtitle: 'Masa başı iş, çok az egzersiz',
      icon: Icons.weekend,
    ),
    ActivityOption(
      id: NutritionCalculatorService.activityLightlyActive,
      title: 'Hafif Aktif',
      subtitle: 'Haftada 1-3 gün hafif egzersiz',
      icon: Icons.directions_walk,
    ),
    ActivityOption(
      id: NutritionCalculatorService.activityModeratelyActive,
      title: 'Orta Aktif',
      subtitle: 'Haftada 3-5 gün egzersiz',
      icon: Icons.directions_run,
    ),
    ActivityOption(
      id: NutritionCalculatorService.activityActive,
      title: 'Aktif',
      subtitle: 'Haftada 6-7 gün yoğun egzersiz',
      icon: Icons.sports_martial_arts,
    ),
    ActivityOption(
      id: NutritionCalculatorService.activityVeryActive,
      title: 'Çok Aktif',
      subtitle: 'Günlük yoğun egzersiz veya fiziksel iş',
      icon: Icons.sports_gymnastics,
    ),
  ];

  void setGoal(String goal) {
    _selectedGoal = goal;
    notifyListeners();
  }

  void setGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setAge(int value) {
    _age = value;
    notifyListeners();
  }

  void setWeight(double value) {
    _weight = value;
    notifyListeners();
  }

  void setHeight(double value) {
    _height = value;
    notifyListeners();
  }

  void setActivityLevel(String level) {
    _selectedActivityLevel = level;
    notifyListeners();
  }

  void setDisplayName(String name) {
    _displayName = name;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setPasswordConfirm(String value) {
    _passwordConfirm = value;
    notifyListeners();
  }

  void toggleEmailForm() {
    _showEmailForm = !_showEmailForm;
    notifyListeners();
  }

  void showEmailFormView() {
    _showEmailForm = true;
    notifyListeners();
  }

  void hideEmailForm() {
    _showEmailForm = false;
    notifyListeners();
  }

  bool canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGoal != null;
      case 1:
        return true; // Cinsiyet her zaman seçili
      case 2:
        return _age > 0 && _weight > 0 && _height > 0;
      case 3:
        return true; // Aktivite her zaman seçili
      case 4:
        return true; // Özet sayfası
      case 5:
        return _displayName.trim().length >= 2; // Kullanıcı adı
      case 6:
        return true; // Giriş yöntemi seçimi
      default:
        return false;
    }
  }

  void nextPage() {
    if (_currentPage < totalPages - 1) {
      // Özet sayfasına geçerken hedefleri hesapla
      if (_currentPage == 3) {
        _calculateTargets();
      }
      
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      // E-posta formu açıksa önce onu kapat
      if (_showEmailForm) {
        _showEmailForm = false;
        notifyListeners();
        return;
      }
      
      pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _currentPage--;
      notifyListeners();
    }
  }

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void _calculateTargets() {
    final isMale = _selectedGender == 'Erkek';
    _calculatedTargets = NutritionCalculatorService.calculateAllTargets(
      weight: _weight,
      height: _height,
      age: _age,
      isMale: isMale,
      activityLevel: _selectedActivityLevel,
      goal: _selectedGoal!,
    );
    notifyListeners();
  }

  /// Giriş sayfasına git (mevcut hesaba giriş için)
  void goToLogin() {
    // Önce sayfayı değiştir, sonra anonim oturumu arka planda kapat
    _navigationService.clearStackAndShow(Routes.loginView);
    // Arka planda oturumu kapat (beklemeden)
    _authService.signOut().catchError((_) {});
  }

  /// Google ile kayıt ol ve onboarding'i tamamla
  Future<void> signUpWithGoogle() async {
    if (_selectedGoal == null) return;

    // KVKK ve Sağlık verisi onayı kontrolü
    if (!_acceptKvkk || !_acceptHealth) {
      setError('Devam etmek için tüm onayları vermelisiniz');
      return;
    }

    setBusy(true);
    try {
      print('🔄 Google ile kayıt başlıyor...');
      
      // Önce anonim hesabı Google ile bağla
      final userId = await _authService.linkWithGoogle();
      
      if (userId == null) {
        setError('Google ile kayıt iptal edildi');
        return;
      }
      
      // Hesap zaten var mı ve onboarding tamamlanmış mı kontrol et
      final existingProfile = await ProfileService.fetchProfile(userId);
      if (existingProfile != null && existingProfile['onboarding_completed'] == true) {
        // Hesap zaten kayıtlı ve onboarding tamamlanmış
        print('ℹ️ Hesap zaten kayıtlı, giriş yapılıyor...');
        _navigationService.clearStackAndShow(Routes.mainView);
        return;
      }
      
      // KVKK onaylarını kaydet
      await _saveConsent();
      
      // Onboarding verilerini kaydet
      await _saveOnboardingData();
      
      print('✅ Google ile kayıt başarılı!');
      _navigationService.clearStackAndShow(Routes.mainView);
    } catch (e, stackTrace) {
      print('❌ Google kayıt hatası: $e');
      print('Stack trace: $stackTrace');
      
      // Google için hesap zaten varsa direkt giriş yap, hata gösterme
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('already registered') || 
          errorStr.contains('already been registered') ||
          errorStr.contains('user already exists') ||
          errorStr.contains('duplicate') ||
          errorStr.contains('email_exists')) {
        // Hesap zaten var, direkt ana sayfaya yönlendir
        print('ℹ️ Google hesabı zaten kayıtlı, giriş yapılıyor...');
        _navigationService.clearStackAndShow(Routes.mainView);
        return;
      } else {
        setError('Google ile kayıt sırasında bir hata oluştu: $e');
      }
    } finally {
      setBusy(false);
    }
  }

  /// E-posta ile kayıt ol ve onboarding'i tamamla
  Future<void> signUpWithEmail() async {
    if (_selectedGoal == null) return;
    
    // Validasyonlar
    if (_email.trim().isEmpty) {
      setError('Lütfen e-posta adresinizi girin');
      return;
    }
    
    final strongPassword = RegExp(r'^(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$');
    if (!strongPassword.hasMatch(_password)) {
      setError('Şifre en az 8 karakter, 1 büyük harf ve 1 özel karakter içermeli');
      return;
    }
    
    if (_password != _passwordConfirm) {
      setError('Şifreler uyuşmuyor');
      return;
    }

    // KVKK ve Sağlık verisi onayı kontrolü
    if (!_acceptKvkk || !_acceptHealth) {
      setError('Devam etmek için tüm onayları vermelisiniz');
      return;
    }

    setBusy(true);
    try {
      print('🔄 E-posta ile kayıt başlıyor...');
      
      // Anonim hesabı e-posta ile bağla
      final userId = await _authService.linkWithEmail(
        email: _email.trim(),
        password: _password,
        displayName: _displayName.trim(),
      );
      
      if (userId == null) {
        setError('E-posta ile kayıt başarısız');
        return;
      }
      
      // KVKK onaylarını kaydet
      await _saveConsent();
      
      // Onboarding verilerini kaydet
      await _saveOnboardingData();
      
      print('✅ E-posta ile kayıt başarılı!');
      _navigationService.clearStackAndShow(Routes.mainView);
    } catch (e, stackTrace) {
      print('❌ E-posta kayıt hatası: $e');
      print('Stack trace: $stackTrace');
      
      // "User already registered" hatası kontrolü
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('already registered') || 
          errorStr.contains('already been registered') ||
          errorStr.contains('user already exists') ||
          errorStr.contains('duplicate') ||
          errorStr.contains('email already in use') ||
          errorStr.contains('email_exists')) {
        setError('Bu e-posta adresi zaten kayıtlı. Lütfen "Zaten hesabım var" seçeneğini kullanarak giriş yapın.');
      } else {
        setError('E-posta ile kayıt sırasında bir hata oluştu: $e');
      }
    } finally {
      setBusy(false);
    }
  }

  /// KVKK ve sağlık verisi onaylarını kaydet
  Future<void> _saveConsent() async {
    try {
      final consentService = locator<ConsentService>();
      await consentService.saveConsent(
        kvkkAccepted: _acceptKvkk,
        healthAccepted: _acceptHealth,
      );
    } catch (e) {
      print('❌ Consent kaydetme hatası: $e');
    }
  }

  /// Onboarding verilerini kaydet (ortak metod)
  Future<void> _saveOnboardingData() async {
    await ProfileService.saveOnboardingData(
      age: _age,
      weight: _weight,
      height: _height,
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
      goal: _selectedGoal!,
      displayName: _displayName.trim(),
    );
  }

  /// Eski completeOnboarding metodu - artık kullanılmıyor
  Future<void> completeOnboarding() async {
    // Bu metod artık signUpWithEmail veya signUpWithGoogle ile değiştirildi
    // Geriye dönük uyumluluk için burada bırakıyoruz
    await signUpWithEmail();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class GoalOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  GoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class ActivityOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  ActivityOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

