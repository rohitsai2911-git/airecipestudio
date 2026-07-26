import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';

class ShoppingFab extends StatelessWidget {
  final VoidCallback onTap;

  const ShoppingFab({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [AppShadows.vibrantButton],
          ),
          child: const Icon(Icons.shopping_cart),
        ),
      ),
    );
  }
}
