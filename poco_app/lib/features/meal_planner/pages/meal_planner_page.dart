import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/design_system/widgets/poco_app_bar.dart';
import '../../../core/design_system/widgets/meal_card.dart';
import '../../../core/models/meal_plan_entry.dart';
import '../providers/meal_plan_provider.dart';
import '../widgets/day_selector.dart';
import '../widgets/smart_suggestions.dart';
import '../widgets/shopping_fab.dart';

class MealPlannerPage extends ConsumerWidget {
  const MealPlannerPage({super.key});

  static const _slots = ['breakfast', 'lunch', 'dinner', 'snack'];
  static const _slotLabels = {'breakfast': 'Breakfast', 'lunch': 'Lunch', 'dinner': 'Dinner', 'snack': 'Snack'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final weekDays = ref.watch(weekDaysProvider);
    final weekDates = ref.watch(weekDatesProvider);
    final dateLabels = ref.watch(weekDatesProvider);
    final startDate = ref.watch(weekStartDateProvider);
    final entries = ref.watch(mealPlanSlotsProvider);
    final recipesAsync = ref.watch(allRecipesForPlannerProvider);

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final selectedDate = monday.add(Duration(days: selectedDay));
    final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final dayEntries = entries[dateStr] ?? {};

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: PocoAppBar(title: 'Meal Planner'),
                ),
                SliverToBoxAdapter(
                  child: DaySelector(
                    selectedDay: selectedDay,
                    labels: weekDays,
                    dates: dateLabels,
                    onDaySelected: (index) =>
                        ref.read(selectedDayProvider.notifier).state = index,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerPadding,
                    ),
                    child: Column(
                      children: _slots.map((slot) {
                        final entry = dayEntries[slot];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, left: 4),
                                child: Text(
                                  _slotLabels[slot] ?? slot,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              MealCard(
                                title: entry != null ? _recipeTitleFor(ref, entry.recipeId) : _slotLabels[slot] ?? slot,
                                calories: 0,
                                isEmpty: entry == null,
                                onTap: entry == null
                                    ? () => _pickRecipe(context, ref, dateStr, slot, recipesAsync)
                                    : () => _showOptions(context, ref, entry),
                                onSwap: entry != null ? () => _pickRecipe(context, ref, dateStr, slot, recipesAsync) : null,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.stackLg,
                      bottom: AppSpacing.stackSm,
                      left: AppSpacing.containerPadding,
                    ),
                    child: Text(
                      'Smart suggestions',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SmartSuggestions(suggestions: []),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
            ShoppingFab(
              onTap: () => context.push('/shopping-list'),
            ),
          ],
        ),
      ),
    );
  }

  String _recipeTitleFor(WidgetRef ref, String recipeId) {
    final recipes = ref.read(allRecipesForPlannerProvider).valueOrNull ?? [];
    final found = recipes.where((r) => r.id == recipeId);
    return found.isNotEmpty ? found.first.dish.title : 'Recipe';
  }

  void _pickRecipe(BuildContext context, WidgetRef ref, String date, String slot, AsyncValue<List> recipesAsync) {
    recipesAsync.whenData((recipes) {
      if (recipes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save some recipes first!')),
        );
        return;
      }
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SizedBox(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Choose a recipe', style: Theme.of(context).textTheme.titleMedium),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (_, i) {
                    final r = recipes[i] as dynamic;
                    return ListTile(
                      leading: const Icon(Icons.restaurant),
                      title: Text(r.dish.title),
                      subtitle: Text(r.dish.cuisine),
                      onTap: () {
                        upsertMealPlan(ref, date, slot, r.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showOptions(BuildContext context, WidgetRef ref, MealPlanEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Remove', style: TextStyle(color: AppColors.error)),
              onTap: () {
                deleteMealPlan(ref, entry.id);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}