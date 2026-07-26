import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/cuisine_card.dart';
import '../../../core/design_system/widgets/difficulty_button.dart';
import '../../../core/design_system/widgets/preference_radio.dart';
import '../../../core/design_system/widgets/servings_slider.dart';
import '../../../core/design_system/widgets/tactile_button.dart';
import '../providers/preferences_provider.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Your Preferences'), backgroundColor: AppColors.surface),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cuisine', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.stackMd),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _cuisineCard('Italian', Icons.restaurant, prefs.cuisine == 'Italian', () => notifier.setCuisine('Italian')),
                    _cuisineCard('Asian', Icons.ramen_dining, prefs.cuisine == 'Asian', () => notifier.setCuisine('Asian')),
                    _cuisineCard('Mexican', Icons.local_pizza, prefs.cuisine == 'Mexican', () => notifier.setCuisine('Mexican')),
                    _cuisineCard('Indian', Icons.restaurant_menu, prefs.cuisine == 'Indian', () => notifier.setCuisine('Indian')),
                    _cuisineCard('American', Icons.fastfood, prefs.cuisine == 'American', () => notifier.setCuisine('American')),
                    _cuisineCard('Mediterranean', Icons.rice_bowl, prefs.cuisine == 'Mediterranean', () => notifier.setCuisine('Mediterranean')),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Text('Difficulty', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.stackMd),
              Row(children: [
                DifficultyButton(label: 'Beginner', isActive: prefs.difficulty == 'beginner', onTap: () => notifier.setDifficulty('beginner')),
                const SizedBox(width: 8),
                DifficultyButton(label: 'Intermediate', isActive: prefs.difficulty == 'intermediate', onTap: () => notifier.setDifficulty('intermediate')),
                const SizedBox(width: 8),
                DifficultyButton(label: 'Advanced', isActive: prefs.difficulty == 'advanced', onTap: () => notifier.setDifficulty('advanced')),
              ]),
              const SizedBox(height: AppSpacing.stackLg),
              Text('Time Limit', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.stackMd),
              PreferenceRadio(label: 'Under 15 min', subtitle: 'Quick meals', isSelected: prefs.timeLimitMinutes == 15, onTap: () => notifier.setTimeLimit(15)),
              const SizedBox(height: 8),
              PreferenceRadio(label: '30 min', subtitle: 'Standard', isSelected: prefs.timeLimitMinutes == 30, onTap: () => notifier.setTimeLimit(30)),
              const SizedBox(height: 8),
              PreferenceRadio(label: '60 min', subtitle: 'Leisurely', isSelected: prefs.timeLimitMinutes == 60, onTap: () => notifier.setTimeLimit(60)),
              const SizedBox(height: 8),
              PreferenceRadio(label: 'No limit', subtitle: 'Take your time', isSelected: prefs.timeLimitMinutes == 0, onTap: () => notifier.setTimeLimit(0)),
              const SizedBox(height: AppSpacing.stackLg),
              Text('Servings', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.stackMd),
              ServingsSlider(value: prefs.servings, onChanged: (v) => notifier.setServings(v)),
              const SizedBox(height: AppSpacing.stackLg),
              SizedBox(
                width: double.infinity,
                child: TactileButton(text: 'Generate Recipes', onPressed: () => context.go('/generate')),
              ),
              const SizedBox(height: AppSpacing.stackLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cuisineCard(String label, IconData icon, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CuisineCard(label: label, icon: icon, isActive: active, onTap: onTap),
    );
  }
}
