import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class MealPlanDay extends StatelessWidget {
  final String label;
  final String date;
  final bool isActive;
  final bool hasMeals;
  final VoidCallback? onTap;

  const MealPlanDay({
    super.key,
    required this.label,
    required this.date,
    this.isActive = false,
    this.hasMeals = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64, height: 80,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryFixed : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outlineVariant.withAlpha(76),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            )),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            )),
            if (hasMeals) ...[
              const SizedBox(height: 4),
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
