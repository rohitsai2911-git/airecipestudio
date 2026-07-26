import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class TimeChip extends StatelessWidget {
  final int minutes;

  const TimeChip({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 12, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text('${minutes}m', style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant,
          )),
        ],
      ),
    );
  }
}
