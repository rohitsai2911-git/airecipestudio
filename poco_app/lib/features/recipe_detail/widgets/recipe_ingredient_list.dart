import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/ingredient.dart';

class RecipeIngredientList extends StatelessWidget {
  final List<Ingredient> ingredients;
  final double scaleFactor;

  const RecipeIngredientList({
    super.key,
    required this.ingredients,
    this.scaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ingredients.map((ingredient) {
        final scaledQty = _scaleQuantity(ingredient.quantity, scaleFactor);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: AppSpacing.stackSm),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  ingredient.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                ),
              ),
              Text(
                '$scaledQty ${ingredient.unit}'.trim(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _scaleQuantity(String qty, double factor) {
    if (factor == 1.0) return qty;
    final parsed = double.tryParse(qty);
    if (parsed == null) return qty;
    final scaled = parsed * factor;
    if (scaled == scaled.roundToDouble()) {
      return scaled.toInt().toString();
    }
    return scaled.toStringAsFixed(1);
  }
}
