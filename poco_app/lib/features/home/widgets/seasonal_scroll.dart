import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

class SeasonalScroll extends StatelessWidget {
  const SeasonalScroll({super.key});

  final _recipes = const [
    ('Spring Green Salad', 'Light, fresh, and local ingredients.', '15'),
    ('Golden Squash Bisque', 'Silky texture with roasted seeds.', '25'),
    ('Wild Pan-Seared Salmon', 'High protein & Omega-3 rich.', '20'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Seasonal Discoveries', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.onSurface, fontSize: 22,
            )),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackMd),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: AppSpacing.containerPadding),
            itemCount: _recipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.gutter),
            itemBuilder: (context, index) {
              final recipe = _recipes[index];
              return Container(
                width: 260,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: const [AppShadows.card],
                  border: Border.all(color: const Color(0x082D2D2D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                      ),
                      child: Center(
                        child: Icon(Icons.image_outlined, size: 48, color: AppColors.onSurfaceVariant.withAlpha(100)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.stackMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.$1, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                          const SizedBox(height: 4),
                          Text(recipe.$2, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
