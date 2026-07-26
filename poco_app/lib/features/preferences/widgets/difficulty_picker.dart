import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/difficulty_button.dart';

class DifficultyPicker extends StatelessWidget {
  final String? selectedDifficulty;
  final ValueChanged<String> onSelected;

  const DifficultyPicker({super.key, required this.selectedDifficulty, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      DifficultyButton(label: 'Beginner', isActive: selectedDifficulty == 'beginner', onTap: () => onSelected('beginner')),
      const SizedBox(width: AppSpacing.stackSm),
      DifficultyButton(label: 'Intermediate', isActive: selectedDifficulty == 'intermediate', onTap: () => onSelected('intermediate')),
      const SizedBox(width: AppSpacing.stackSm),
      DifficultyButton(label: 'Advanced', isActive: selectedDifficulty == 'advanced', onTap: () => onSelected('advanced')),
    ]);
  }
}
