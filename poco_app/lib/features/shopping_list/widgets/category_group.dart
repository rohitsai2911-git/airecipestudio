import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/shopping_list_provider.dart';
import '../../../core/design_system/widgets/shopping_list_tile.dart';

class CategoryGroup extends StatelessWidget {
  final String category;
  final List<ShoppingItem> items;
  final ValueChanged<String> onToggle;

  const CategoryGroup({
    super.key,
    required this.category,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ShoppingListTile(
                name: item.name,
                quantity: item.quantity,
                isChecked: item.checked,
                onChanged: (_) => onToggle(item.name),
              ),
            )),
      ],
    );
  }
}
