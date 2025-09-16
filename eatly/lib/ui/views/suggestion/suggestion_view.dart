import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'suggestion_viewmodel.dart';
import '../../../core/theme/app_theme.dart';

class SuggestionView extends StackedView<SuggestionViewModel> {
  const SuggestionView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SuggestionViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Yemek Önerileri'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, viewModel),
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewModel.refreshSuggestions,
              child: Column(
                children: [
                  _buildCategoryFilter(context, viewModel),
                  _buildDietaryPreferences(context, viewModel),
                  Expanded(
                    child: _buildSuggestionsList(context, viewModel),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, SuggestionViewModel viewModel) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final isSelected = category == viewModel.selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => viewModel.selectCategory(category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDietaryPreferences(BuildContext context, SuggestionViewModel viewModel) {
    if (!viewModel.isVegetarian && !viewModel.isVegan && !viewModel.isGlutenFree) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Aktif Filtreler: '),
          if (viewModel.isVegan)
            _buildPreferenceChip('Vegan', Colors.green),
          if (viewModel.isVegetarian && !viewModel.isVegan)
            _buildPreferenceChip('Vejetaryen', Colors.orange),
          if (viewModel.isGlutenFree)
            _buildPreferenceChip('Glutensiz', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildPreferenceChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context, SuggestionViewModel viewModel) {
    final suggestions = viewModel.filteredSuggestions;
    
    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Bu kriterlere uygun öneri bulunamadı',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                viewModel.selectCategory('Tümü');
              },
              child: const Text('Filtreleri Temizle'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _buildSuggestionCard(context, viewModel, suggestion);
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    SuggestionViewModel viewModel,
    FoodSuggestion suggestion,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => viewModel.selectSuggestion(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: suggestion.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          suggestion.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.restaurant,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            suggestion.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(suggestion.category),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            suggestion.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${suggestion.calories} kcal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (suggestion.isVegan)
                          _buildTag('V', Colors.green)
                        else if (suggestion.isVegetarian)
                          _buildTag('VEJ', Colors.orange),
                        if (suggestion.isGlutenFree)
                          _buildTag('GF', Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Kahvaltı':
        return Colors.amber;
      case 'Öğle Yemeği':
        return Colors.blue;
      case 'Akşam Yemeği':
        return Colors.purple;
      case 'Atıştırmalık':
        return Colors.teal;
      case 'İçecek':
        return Colors.cyan;
      default:
        return AppTheme.primaryColor;
    }
  }

  void _showFilterDialog(BuildContext context, SuggestionViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diyet Tercihleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Vejetaryen'),
              value: viewModel.isVegetarian,
              onChanged: (_) => viewModel.toggleVegetarian(),
              activeColor: AppTheme.primaryColor,
            ),
            CheckboxListTile(
              title: const Text('Vegan'),
              value: viewModel.isVegan,
              onChanged: (_) => viewModel.toggleVegan(),
              activeColor: AppTheme.primaryColor,
            ),
            CheckboxListTile(
              title: const Text('Glutensiz'),
              value: viewModel.isGlutenFree,
              onChanged: (_) => viewModel.toggleGlutenFree(),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  SuggestionViewModel viewModelBuilder(BuildContext context) => SuggestionViewModel();

  @override
  void onViewModelReady(SuggestionViewModel viewModel) {
    viewModel.initialize();
  }
}