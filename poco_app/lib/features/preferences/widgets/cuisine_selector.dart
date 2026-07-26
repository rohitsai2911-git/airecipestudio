import 'package:flutter/material.dart';
import '../../../core/design_system/widgets/cuisine_card.dart';
import '../../../core/theme/app_spacing.dart';

class CuisineSelector extends StatelessWidget {
  final String? selectedCuisine;
  final ValueChanged<String> onSelected;

  const CuisineSelector({super.key, required this.selectedCuisine, required this.onSelected});

  final List<_CuisineOption> _cuisines = const [
    _CuisineOption('Italian', Icons.restaurant),
    _CuisineOption('Asian', Icons.ramen_dining),
    _CuisineOption('Mexican', Icons.local_pizza),
    _CuisineOption('Indian', Icons.restaurant_menu),
    _CuisineOption('American', Icons.fastfood),
    _CuisineOption('Mediterranean', Icons.rice_bowl),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _cuisines.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.stackSm),
        itemBuilder: (context, i) {
          final c = _cuisines[i];
          return CuisineCard(
            label: c.label,
            icon: c.icon,
            isActive: selectedCuisine == c.label,
            onTap: () => onSelected(c.label),
          );
        },
      ),
    );
  }
}

class _CuisineOption {
  final String label;
  final IconData icon;
  const _CuisineOption(this.label, this.icon);
}
