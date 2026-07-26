import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class ShoppingListTile extends StatelessWidget {
  final String name;
  final String quantity;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;

  const ShoppingListTile({
    super.key,
    required this.name,
    required this.quantity,
    this.isChecked = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: AppColors.surfaceContainerLowest,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24, height: 24,
            child: Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked ? AppColors.onSurfaceVariant : AppColors.onSurface,
              ),
            ),
          ),
          Text(
            quantity,
            style: const TextStyle(
              fontSize: 13, color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
