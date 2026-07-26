import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/design_system/widgets/poco_mascot_tip.dart';
import '../providers/recipe_detail_provider.dart';
import '../widgets/recipe_hero.dart';
import '../widgets/recipe_stats_row.dart';
import '../widgets/recipe_ingredient_list.dart';
import '../widgets/recipe_step_list.dart';
import '../widgets/recipe_bottom_bar.dart';

class RecipeDetailPage extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(recipeIdProvider.notifier).state = recipeId;
    final recipeAsync = ref.watch(recipeDetailProvider);
    final scale = ref.watch(servingsScaleProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: recipeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (recipe) {
          if (recipe == null) {
            return const Center(child: Text('Recipe not found'));
          }
          final dish = recipe.dish;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: RecipeHero(
                      title: dish.title,
                      isBookmarked: recipe.bookmarked,
                      onBack: () => context.pop(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.containerPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.stackMd),
                          RecipeStatsRow(
                            cookTimeMinutes: dish.cookTimeMinutes,
                            servings: dish.servings,
                            difficulty: 'Easy',
                            calories: 320,
                          ),
                          const SizedBox(height: AppSpacing.stackMd),
                          Wrap(
                            spacing: AppSpacing.unit,
                            children: [
                              _TagPill(label: 'High Fiber'),
                              _TagPill(label: 'Vegan'),
                              _TagPill(label: 'Gluten-Free'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.stackLg),
                          Text(
                            'Ingredients',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.stackSm),
                          Row(
                            children: [
                              const Text('Servings:'),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: scale > 1
                                    ? () => ref.read(servingsScaleProvider.notifier).state = scale - 1
                                    : null,
                                color: AppColors.primary,
                              ),
                              Text('$scale', style: const TextStyle(fontWeight: FontWeight.w600)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => ref.read(servingsScaleProvider.notifier).state = scale + 1,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.stackSm),
                          RecipeIngredientList(
                            ingredients: dish.ingredients,
                            scaleFactor: scale.toDouble(),
                          ),
                          const SizedBox(height: AppSpacing.stackLg),
                          Text(
                            'Steps',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.stackMd),
                          RecipeStepList(steps: dish.steps),
                          const SizedBox(height: AppSpacing.stackLg),
                          const PocoMascotTip(
                            tip:
                                'Toasting your spices in a dry pan for 30 seconds before cooking unlocks deeper flavors and aromas.',
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: RecipeBottomBar(
                  onStartCooking: () => context.push('/voice-cooking/$recipeId'),
                  isBookmarked: recipe.bookmarked,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
