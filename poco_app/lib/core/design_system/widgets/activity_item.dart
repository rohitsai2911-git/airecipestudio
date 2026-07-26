import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String xpAmount;
  final String timestamp;
  final Color? iconColor;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.xpAmount,
    required this.timestamp,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withAlpha(25),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                )),
                Text(timestamp, style: const TextStyle(
                  fontSize: 12, color: AppColors.onSurfaceVariant,
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text('+$xpAmount XP', style: const TextStyle(
              fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    );
  }
}
