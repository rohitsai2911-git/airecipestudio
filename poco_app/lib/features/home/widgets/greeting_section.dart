import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/providers/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GreetingSection extends ConsumerWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting, Chef!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppColors.onSurface,
        )),
        const SizedBox(height: 4),
        Text('Ready to whip up something fresh today?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
