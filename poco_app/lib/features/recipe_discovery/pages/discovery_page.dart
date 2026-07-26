import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/design_system/widgets/poco_app_bar.dart';
import '../../../core/design_system/widgets/filter_chip.dart';
import '../../../core/design_system/widgets/recipe_card.dart';
import '../providers/discovery_provider.dart';

class DiscoveryPage extends ConsumerWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(activeFilterProvider);
    final recipesAsync = ref.watch(discoveryRecipesProvider);
    final filters = ['All Recipes', 'Quick Bites', 'Low Carb', 'High Protein', 'Vegetarian'];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: PocoAppBar(title: 'Discover')),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                  itemCount: filters.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChipWidget(
                      label: filters[i],
                      isActive: activeFilter == filters[i],
                      onTap: () => ref.read(activeFilterProvider.notifier).state = filters[i],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    color: AppColors.primaryFixed,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppRadius.lg),
                              bottomLeft: Radius.circular(AppRadius.lg),
                            ),
                            color: AppColors.primaryContainer.withAlpha(51),
                          ),
                          child: const Center(child: Icon(Icons.restaurant, size: 64, color: AppColors.primaryContainer)),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Text("Chef's Choice", style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 8),
                              Text('Recommended for you', style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: 4),
                              Text('Based on your preferences', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            recipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.containerPadding),
                      child: Center(
                        child: Text(
                          'Save some recipes to see them here!',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => DiscoveryCard(
                        title: recipes[i].dish.title,
                        description: recipes[i].dish.cuisine,
                        cookTimeMinutes: recipes[i].dish.cookTimeMinutes,
                        matchPercentage: 85.0,
                        rating: 4.5,
                        difficulty: 'Easy',
                        onTap: () => context.push('/recipes/${recipes[i].id}'),
                      ),
                      childCount: recipes.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Failed to load recipes'),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}