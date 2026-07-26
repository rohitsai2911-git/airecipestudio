import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/recipe_card.dart';

class DiscoveryGrid extends StatelessWidget {
  final int itemCount;
  final String Function(int) titleAt;
  final String Function(int) descAt;
  final int Function(int) timeAt;

  const DiscoveryGrid({
    super.key,
    required this.itemCount,
    required this.titleAt,
    required this.descAt,
    required this.timeAt,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: itemCount,
          itemBuilder: (_, i) => DiscoveryCard(
            title: titleAt(i),
            description: descAt(i),
            cookTimeMinutes: timeAt(i),
            matchPercentage: 85.0,
            rating: 4.5,
            difficulty: 'Easy',
          ),
        );
      },
    );
  }
}
