import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/models/saved_recipe.dart';

class LibraryGrid extends ConsumerWidget {
  final AsyncValue<List<SavedRecipe>> recipes;

  const LibraryGrid({super.key, required this.recipes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return recipes.when(
      loading: () => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildShimmerFeatured(context)),
          SliverPadding(
            padding: const EdgeInsets.only(top: AppSpacing.stackMd),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.gutter,
                mainAxisSpacing: AppSpacing.gutter,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, index) => _buildShimmerCard(context),
                childCount: 6,
              ),
            ),
          ),
        ],
      ),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book, size: 64, color: AppColors.outlineVariant),
                const SizedBox(height: AppSpacing.stackMd),
                Text(
                  'No recipes yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: const [AppShadows.card],
                  ),
                  child: Center(
                    child: Text(
                      'Featured Recipe',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.stackMd),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.gutter,
                  mainAxisSpacing: AppSpacing.gutter,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, index) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: const [AppShadows.card],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withAlpha(25),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppRadius.lg),
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.restaurant, color: AppColors.primaryContainer, size: 32),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Recipe ${index + 2}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  childCount: items.isNotEmpty ? items.length - 1 : 4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerFeatured(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}
