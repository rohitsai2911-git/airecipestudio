import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/design_system/widgets/ingredient_chip.dart';
import '../../../core/design_system/widgets/tactile_button.dart';

class IngredientSheet extends StatefulWidget {
  final List<String> ingredients;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onGenerate;

  const IngredientSheet({
    super.key,
    required this.ingredients,
    required this.onAdd,
    required this.onRemove,
    required this.onGenerate,
  });

  @override
  State<IngredientSheet> createState() => _IngredientSheetState();
}

class _IngredientSheetState extends State<IngredientSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxxl),
          topRight: Radius.circular(AppRadius.xxxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(height: AppSpacing.stackMd),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Add ingredient...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    widget.onAdd(_controller.text.trim());
                    _controller.clear();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Wrap(spacing: 8, runSpacing: 8,
            children: widget.ingredients.map((i) => IngredientChip(
              label: i, onRemove: () => widget.onRemove(i),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          SizedBox(
            width: double.infinity,
            child: TactileButton(
              text: 'Generate Recipes',
              onPressed: widget.ingredients.isEmpty ? null : widget.onGenerate,
            ),
          ),
        ],
      ),
    );
  }
}
