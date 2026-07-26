import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../providers/generation_provider.dart';

class GenerationPage extends ConsumerWidget {
  const GenerationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(generationProvider);
    final notifier = ref.read(generationProvider.notifier);

    ref.listen<GenerationState>(generationProvider, (_, next) {
      if (next.status == GenerationStatus.success) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!context.mounted) return;
          context.go('/discover');
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [AppShadows.mascotCard],
                ),
                child: const Icon(Icons.pets, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Text("Poco is thinking...", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.stackLg),
              if (state.status == GenerationStatus.generating)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.outlineVariant,
                    color: AppColors.primaryContainer,
                    minHeight: 6,
                  ),
                ),
              if (state.status == GenerationStatus.error) ...[
                const SizedBox(height: AppSpacing.stackMd),
                Text(state.errorMessage ?? 'Something went wrong', style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: AppSpacing.stackMd),
                ElevatedButton(onPressed: () => notifier.generate(), child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
