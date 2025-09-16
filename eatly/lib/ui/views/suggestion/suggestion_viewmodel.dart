import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';

class SuggestionViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  
  // Öneriler listesi
  final List<FoodSuggestion> _suggestions = [];
  List<FoodSuggestion> get suggestions => _suggestions;
  
  // Filtreler
  String _selectedCategory = 'Tümü';
  String get selectedCategory => _selectedCategory;
  
  final List<String> categories = [
    'Tümü',
    'Kahvaltı',
    'Öğle Yemeği',
    'Akşam Yemeği',
    'Atıştırmalık',
    'İçecek',
  ];
  
  // Kullanıcı tercihleri
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isGlutenFree = false;
  
  bool get isVegetarian => _isVegetarian;
  bool get isVegan => _isVegan;
  bool get isGlutenFree => _isGlutenFree;
  
  Future<void> initialize() async {
    setBusy(true);
    try {
      await loadSuggestions();
      await loadUserPreferences();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Öneriler yüklenemedi: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }
  
  Future<void> loadSuggestions() async {
    // Backend'den önerileri yükle
    await Future.delayed(const Duration(seconds: 1)); // Simülasyon
    
    _suggestions.addAll([
      FoodSuggestion(
        name: 'Yeşil Salata',
        category: 'Öğle Yemeği',
        calories: 150,
        description: 'Taze sebzelerle hazırlanmış sağlıklı salata',
        imageUrl: '',
        isVegetarian: true,
        isVegan: true,
        isGlutenFree: true,
      ),
      FoodSuggestion(
        name: 'Tavuk Göğsü',
        category: 'Akşam Yemeği',
        calories: 350,
        description: 'Izgara tavuk göğsü, sebze garnitürlü',
        imageUrl: '',
        isVegetarian: false,
        isVegan: false,
        isGlutenFree: true,
      ),
      FoodSuggestion(
        name: 'Yulaf Ezmesi',
        category: 'Kahvaltı',
        calories: 250,
        description: 'Meyve ve fındıklı yulaf ezmesi',
        imageUrl: '',
        isVegetarian: true,
        isVegan: false,
        isGlutenFree: false,
      ),
      FoodSuggestion(
        name: 'Protein Bar',
        category: 'Atıştırmalık',
        calories: 180,
        description: 'Yüksek proteinli atıştırmalık',
        imageUrl: '',
        isVegetarian: true,
        isVegan: false,
        isGlutenFree: false,
      ),
      FoodSuggestion(
        name: 'Yeşil Smoothie',
        category: 'İçecek',
        calories: 120,
        description: 'Ispanak, avokado ve muz ile hazırlanmış',
        imageUrl: '',
        isVegetarian: true,
        isVegan: true,
        isGlutenFree: true,
      ),
    ]);
    
    notifyListeners();
  }
  
  Future<void> loadUserPreferences() async {
    // Kullanıcı tercihlerini yükle
    // SharedPreferences veya backend'den
    notifyListeners();
  }
  
  List<FoodSuggestion> get filteredSuggestions {
    var filtered = _suggestions.where((suggestion) {
      // Kategori filtresi
      if (_selectedCategory != 'Tümü' && suggestion.category != _selectedCategory) {
        return false;
      }
      
      // Diyet tercihleri
      if (_isVegetarian && !suggestion.isVegetarian) return false;
      if (_isVegan && !suggestion.isVegan) return false;
      if (_isGlutenFree && !suggestion.isGlutenFree) return false;
      
      return true;
    }).toList();
    
    return filtered;
  }
  
  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  void toggleVegetarian() {
    _isVegetarian = !_isVegetarian;
    if (_isVegetarian) _isVegan = false; // Vegan değilse vegetarian olabilir
    notifyListeners();
  }
  
  void toggleVegan() {
    _isVegan = !_isVegan;
    if (_isVegan) _isVegetarian = true; // Vegan ise otomatik vegetarian
    notifyListeners();
  }
  
  void toggleGlutenFree() {
    _isGlutenFree = !_isGlutenFree;
    notifyListeners();
  }
  
  void selectSuggestion(FoodSuggestion suggestion) {
    // Öneri seçildiğinde yapılacak işlemler
    _snackbarService.showSnackbar(
      message: '${suggestion.name} seçildi!',
      duration: const Duration(seconds: 2),
    );
  }
  
  Future<void> refreshSuggestions() async {
    setBusy(true);
    _suggestions.clear();
    await loadSuggestions();
    setBusy(false);
  }
}

class FoodSuggestion {
  final String name;
  final String category;
  final int calories;
  final String description;
  final String imageUrl;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  
  FoodSuggestion({
    required this.name,
    required this.category,
    required this.calories,
    required this.description,
    required this.imageUrl,
    required this.isVegetarian,
    required this.isVegan,
    required this.isGlutenFree,
  });
}
