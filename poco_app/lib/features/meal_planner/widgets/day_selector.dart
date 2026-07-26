import 'package:flutter/material.dart';
import '../../../core/design_system/widgets/meal_plan_day.dart';

class DaySelector extends StatelessWidget {
  final int selectedDay;
  final List<String> labels;
  final List<String> dates;
  final ValueChanged<int> onDaySelected;

  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.labels,
    required this.dates,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: labels.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: MealPlanDay(
              label: labels[index],
              date: dates[index],
              isActive: selectedDay == index,
              hasMeals: index == 0 || index == 2,
              onTap: () => onDaySelected(index),
            ),
          );
        },
      ),
    );
  }
}
