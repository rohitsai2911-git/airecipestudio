import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/tactile_button.dart';

class RecipeBottomBar extends StatelessWidget {
  final VoidCallback? onStartCooking;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final bool isBookmarked;

  const RecipeBottomBar({
    super.key,
    this.onStartCooking,
    this.onBookmark,
    this.onShare,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.containerPadding,
        right: AppSpacing.containerPadding,
        top: AppSpacing.stackMd,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.stackMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TactileButton(
              text: 'Start Cooking',
              onPressed: onStartCooking,
              width: double.infinity,
            ),
          ),
          const SizedBox(width: AppSpacing.stackSm),
          IconButton(
            onPressed: onBookmark,
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.primary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withAlpha(25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.stackSm),
          IconButton(
            onPressed: onShare,
            icon: const Icon(Icons.share, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withAlpha(25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
