import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/poco_app_bar.dart';
import '../../../core/design_system/widgets/filter_chip.dart';
import '../providers/library_provider.dart';
import '../widgets/library_search_bar.dart';
import '../widgets/library_grid.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(librarySearchQuery);
    final activeFilter = ref.watch(libraryFilterProvider);
    final recipesAsync = ref.watch(libraryRecipesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PocoAppBar(title: 'My Library'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
              child: LibrarySearchBar(
                query: searchQuery,
                onChanged: (q) => ref.read(librarySearchQuery.notifier).state = q,
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                children: ['All', 'Recently Added', 'Favorites', 'Quick Meals'].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.unit),
                    child: FilterChipWidget(
                      label: filter,
                      isActive: activeFilter == filter,
                      onTap: () => ref.read(libraryFilterProvider.notifier).state = filter,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                child: LibraryGrid(recipes: recipesAsync),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
