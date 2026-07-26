import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/filter_chip.dart';

class FilterChipsRow extends StatelessWidget {
  final List<String> filters;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
        itemCount: filters.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: AppSpacing.stackSm),
          child: FilterChipWidget(
            label: filters[i],
            isActive: activeFilter == filters[i],
            onTap: () => onFilterChanged(filters[i]),
          ),
        ),
      ),
    );
  }
}
