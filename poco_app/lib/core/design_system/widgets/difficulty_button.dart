import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DifficultyButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const DifficultyButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outlineVariant,
            width: isActive ? 2 : 1,
          ),
          color: isActive ? AppColors.primaryFixed.withAlpha(51) : Colors.transparent,
        ),
        child: Text(label, style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          fontSize: 14,
        )),
      ),
    );
  }
}
