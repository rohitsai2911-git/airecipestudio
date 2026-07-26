import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';

class PocoMascotTip extends StatelessWidget {
  final String tip;

  const PocoMascotTip({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.mascotTipBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.mascotCard],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Poco's Pro-Tip", style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary, letterSpacing: 0.05,
                )),
                const SizedBox(height: 4),
                Text(tip, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
