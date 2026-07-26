import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/poco_app_bar.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/category_group.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shoppingListProvider);

    final grouped = <String, List<ShoppingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PocoAppBar(title: 'Shopping List'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                ),
                children: grouped.entries.map((entry) {
                  return CategoryGroup(
                    category: entry.key,
                    items: entry.value,
                    onToggle: (name) =>
                        ref.read(shoppingListProvider.notifier).toggle(name),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
