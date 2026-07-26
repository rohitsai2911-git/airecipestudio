import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_radius.dart';

class PocoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const tabs = (
    icons: [Icons.home, Icons.explore, Icons.menu_book, Icons.military_tech, Icons.person],
    labels: ['Home', 'Discover', 'Library', 'XP', 'Profile'],
    routes: ['/home', '/discover', '/library', '/xp', '/profile'],
  );

  const PocoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [AppShadows.bottomNav],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface.withAlpha(204),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          items: List.generate(
            tabs.labels.length,
            (i) => BottomNavigationBarItem(
              icon: Icon(tabs.icons[i]),
              activeIcon: Icon(tabs.icons[i], fill: 1),
              label: tabs.labels[i],
            ),
          ),
        ),
      ),
    );
  }
}
