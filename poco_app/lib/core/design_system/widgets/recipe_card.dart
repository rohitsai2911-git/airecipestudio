import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import 'time_chip.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final int cookTimeMinutes;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.cookTimeMinutes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 192,
                  color: AppColors.primaryContainer.withAlpha(25),
                  child: imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover, width: double.infinity)
                      : const Center(child: Icon(Icons.restaurant, color: AppColors.primaryContainer, size: 48)),
                ),
                Positioned(top: 8, right: 8, child: TimeChip(minutes: cookTimeMinutes)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.stackMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoveryCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final int cookTimeMinutes;
  final double matchPercentage;
  final double rating;
  final String difficulty;
  final VoidCallback? onTap;

  const DiscoveryCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.cookTimeMinutes,
    required this.matchPercentage,
    required this.rating,
    required this.difficulty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 256,
                  color: AppColors.primaryContainer.withAlpha(25),
                  child: imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover, width: double.infinity)
                      : const Center(child: Icon(Icons.restaurant, color: AppColors.primaryContainer, size: 48)),
                ),
                Positioned(top: 8, right: 8, child: TimeChip(minutes: cookTimeMinutes)),
                Positioned(top: 8, left: 8, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                      const SizedBox(width: 4),
                      Text(rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.stackMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withAlpha(25),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text('${matchPercentage.round()}%', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text(difficulty, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
