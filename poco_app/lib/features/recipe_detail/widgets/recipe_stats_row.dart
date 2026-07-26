import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RecipeStatsRow extends StatelessWidget {
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final int? calories;

  const RecipeStatsRow({
    super.key,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(icon: Icons.access_time, label: '$cookTimeMinutes min'),
        const SizedBox(width: 20),
        _StatItem(icon: Icons.people, label: '$servings servings'),
        const SizedBox(width: 20),
        _StatItem(icon: Icons.bar_chart, label: difficulty),
        if (calories != null) ...[
          const SizedBox(width: 20),
          _StatItem(icon: Icons.local_fire_department, label: '$calories kcal'),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
