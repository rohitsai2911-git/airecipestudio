import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

class HeroRecipeCard extends StatelessWidget {
  const HeroRecipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.card],
        border: Border.all(color: const Color(0x082D2D2D)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.stackLg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text('AI RECOMMENDED',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Text('Zesty Lemon Basil Pasta',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface)),
                  const SizedBox(height: AppSpacing.stackSm),
                  Text('Based on your available ingredients and the sunny morning weather.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.stackMd),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.restaurant, size: 18),
                      label: const Text('Start Cooking'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: const [AppShadows.glowOrange],
              ),
              child: const Icon(Icons.restaurant, size: 48, color: AppColors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
