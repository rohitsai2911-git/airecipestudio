import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/design_system/widgets/tactile_button.dart';

class VoiceControls extends StatelessWidget {
  final VoidCallback onRepeat;
  final VoidCallback onNext;

  const VoiceControls({
    super.key,
    required this.onRepeat,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: TextButton(
              onPressed: onRepeat,
              child: const Text('Repeat'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TactileButton(
            text: 'Next',
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}
