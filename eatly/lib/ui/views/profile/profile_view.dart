import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../theme/app_theme.dart';
import 'profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(title: const Text('Profilim')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _header(model, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(ProfileViewModel model, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5)),
              ],
            ),
            child: Center(
              child: Text(
                model.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(model.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('${model.age} yaşında • ${model.gender}', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}


