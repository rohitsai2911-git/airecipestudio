import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryContainer : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: isActive ? Border.all(color: AppColors.primary, width: 1) : null,
        ),
        child: Text(label, style: TextStyle(
          color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
          fontSize: 14, fontWeight: FontWeight.w500,
        )),
      ),
    );
  }
}
