import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/preference_radio.dart';

class TimeLimitRadio extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onChanged;

  const TimeLimitRadio({super.key, required this.selectedMinutes, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PreferenceRadio(label: 'Under 15 min', subtitle: 'Quick meals', isSelected: selectedMinutes == 15, onTap: () => onChanged(15)),
      const SizedBox(height: AppSpacing.stackSm),
      PreferenceRadio(label: '30 min', subtitle: 'Standard', isSelected: selectedMinutes == 30, onTap: () => onChanged(30)),
      const SizedBox(height: AppSpacing.stackSm),
      PreferenceRadio(label: '60 min', subtitle: 'Leisurely', isSelected: selectedMinutes == 60, onTap: () => onChanged(60)),
      const SizedBox(height: AppSpacing.stackSm),
      PreferenceRadio(label: 'No limit', subtitle: 'Take your time', isSelected: selectedMinutes == 0, onTap: () => onChanged(0)),
    ]);
  }
}
