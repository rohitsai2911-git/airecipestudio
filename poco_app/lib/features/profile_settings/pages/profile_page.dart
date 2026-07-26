import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/poco_app_bar.dart';
import '../providers/profile_provider.dart';
import '../widgets/avatar_section.dart';
import '../widgets/stats_cards.dart';
import '../widgets/settings_list.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileNameProvider);
    final level = ref.watch(profileLevelProvider);
    final stats = ref.watch(profileStatsProvider);
    final dietaryPref = ref.watch(dietaryPrefProvider);
    final mealPlanningPref = ref.watch(mealPlanningPrefProvider);
    final notificationsPref = ref.watch(notificationsPrefProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PocoAppBar(title: 'Profile'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.stackLg,
                ),
                child: AvatarSection(
                  name: name,
                  level: level,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: StatsCards(stats: stats),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_month, color: AppColors.onSurfaceVariant),
                      title: const Text('Meal Planner'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/meal-planner'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart, color: AppColors.onSurfaceVariant),
                      title: const Text('Shopping List'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/shopping-list'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.kitchen, color: AppColors.onSurfaceVariant),
                      title: const Text('Pantry'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/pantry'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.stackLg,
                  left: AppSpacing.containerPadding,
                  right: AppSpacing.containerPadding,
                ),
                child: SettingsList(
                  dietaryPref: dietaryPref,
                  mealPlanningPref: mealPlanningPref,
                  notificationsPref: notificationsPref,
                  isDarkMode: isDarkMode,
                  onDietaryChanged: (value) =>
                      ref.read(dietaryPrefProvider.notifier).state = value,
                  onMealPlanningChanged: (value) =>
                      ref.read(mealPlanningPrefProvider.notifier).state = value,
                  onNotificationsChanged: (value) =>
                      ref.read(notificationsPrefProvider.notifier).state = value,
                  onDarkModeChanged: (value) {
                      ref.read(isDarkModeProvider.notifier).state = value;
                      saveProfile(ref);
                    },
                  onLogout: () => context.go('/login'),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}
