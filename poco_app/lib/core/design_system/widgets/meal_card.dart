import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class MealCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final int calories;
  final bool isEmpty;
  final VoidCallback? onTap;
  final VoidCallback? onSwap;

  const MealCard({
    super.key,
    required this.title,
    this.imageUrl,
    required this.calories,
    this.isEmpty = false,
    this.onTap,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 128,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.outlineVariant, width: 1.5, style: BorderStyle.solid),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: AppColors.onSurfaceVariant, size: 20),
                const SizedBox(width: 4),
                Text('Add meal', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 128,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: AppColors.surfaceContainerLowest,
        ),
        child: Stack(
          children: [
            if (imageUrl != null)
              Positioned.fill(
                child: Image.network(imageUrl!, fit: BoxFit.cover),
              ),
            if (imageUrl == null)
              Positioned.fill(
                child: Container(color: AppColors.primaryContainer.withAlpha(25)),
              ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.stackSm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withAlpha(179), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600,
                      ), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Text('$calories kcal', style: const TextStyle(
                      color: Colors.white70, fontSize: 11,
                    )),
                  ],
                ),
              ),
            ),
            if (onSwap != null)
              Positioned(
                top: 4, right: 4,
                child: GestureDetector(
                  onTap: onSwap,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white24, shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_horiz, color: Colors.white, size: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
