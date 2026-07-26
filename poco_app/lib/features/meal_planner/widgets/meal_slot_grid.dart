import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/design_system/widgets/meal_card.dart';

class MealSlotGrid extends StatelessWidget {
  final Map<String, bool> slotStatus;

  const MealSlotGrid({
    super.key,
    required this.slotStatus,
  });

  static const List<String> defaultSlots = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  @override
  Widget build(BuildContext context) {
    final slots = slotStatus.isEmpty
        ? <String, bool>{
            'Breakfast': true,
            'Lunch': true,
            'Dinner': true,
            'Snack': true,
          }
        : slotStatus;

    return Column(
      children: slots.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              MealCard(
                title: entry.key,
                calories: 0,
                isEmpty: entry.value,
                onTap: () {},
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
