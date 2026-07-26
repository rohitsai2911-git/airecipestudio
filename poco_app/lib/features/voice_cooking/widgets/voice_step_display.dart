import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class VoiceStepDisplay extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;

  const VoiceStepDisplay({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$stepNumber',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
