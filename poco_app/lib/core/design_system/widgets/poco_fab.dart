import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class PocoFab extends StatelessWidget {
  final VoidCallback? onPressed;

  const PocoFab({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: AppSpacing.containerPadding,
      bottom: 24,
      child: SizedBox(
        width: 64, height: 64,
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.bolt, color: AppColors.onPrimary, size: 28),
        ),
      ),
    );
  }
}
