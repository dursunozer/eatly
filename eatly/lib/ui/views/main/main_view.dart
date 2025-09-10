import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/theme/app_theme.dart';
import '../home/home_view.dart';
import '../nutrition/nutrition_view.dart';
import '../profile/profile_view.dart';
import 'main_viewmodel.dart';
import '../../common/pill_nav_bar.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MainViewModel>.reactive(
      viewModelBuilder: () => MainViewModel(),
      builder: (context, model, child) {
        // Sağ alttaki Profil'i kaldırıp onun yerine Detaylar'ı taşıyacağız.
        final screens = [
          // refreshTick değiştiğinde yeni Key ile HomeView yeniden kurulur
          KeyedSubtree(
            key: ValueKey('home-${model.refreshTick}'),
            child: const HomeView(),
          ),
          const ProfileView(),
          const NutritionView(),
        ];
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: screens[model.currentIndex]),
              Positioned(
                left: 0,
                right: 0,
                bottom: 17,
                child: PillNavBar(
                  currentIndex: model.currentIndex,
                  onTap: model.onTabSelected,
                  items: const [
                    PillNavItemData(
                      Icons.home_rounded,
                      'Giriş',
                      outlineIcon: Icons.home_outlined,
                    ),
                    PillNavItemData(
                      Icons.favorite,
                      'Detaylar',
                      outlineIcon: Icons.favorite_border,
                    ),
                    PillNavItemData(
                      Icons.chat_bubble,
                      '',
                      outlineIcon: Icons.chat_bubble_outline,
                    ),
                    PillNavItemData(
                      Icons.person,
                      'Profil',
                      outlineIcon: Icons.person_outline,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 78,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    onPressed: model.goToCamera,
                    backgroundColor: const Color.fromARGB(255, 242, 252, 219),
                    shape: const CircleBorder(),
                    child: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
