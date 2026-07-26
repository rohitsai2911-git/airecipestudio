import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/design_system/widgets/ingredient_chip.dart';
import '../../../core/design_system/widgets/tactile_button.dart';
import '../providers/scanner_provider.dart';

class ScannerPage extends ConsumerWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients = ref.watch(scannedIngredientsProvider);
    final capturedImage = ref.watch(capturedImageProvider);
    final notifier = ref.read(scannedIngredientsProvider.notifier);
    final cameraNotifier = ref.read(cameraNotifierProvider);
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.stackMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Text('Scanner', style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.35,
                child: GestureDetector(
                  onTap: () => cameraNotifier.capture(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      image: capturedImage != null
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(capturedImage)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            capturedImage != null ? Icons.check_circle : Icons.camera_alt,
                            size: 64,
                            color: Colors.white.withAlpha(180),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            capturedImage != null ? 'Photo captured' : 'Tap to take photo',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Add ingredient...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        notifier.add(controller.text.trim());
                        controller.clear();
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    notifier.add(value.trim());
                    controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      ...ingredients.map((i) => IngredientChip(
                        label: i,
                        onRemove: () => notifier.remove(i),
                      )),
                      if (capturedImage != null)
                        IngredientChip(
                          label: '📷 Photo captured',
                          onRemove: () => cameraNotifier.clear(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.containerPadding),
              child: SizedBox(
                width: double.infinity,
                child: TactileButton(
                  text: 'Generate Recipes',
                  onPressed: ingredients.isEmpty && capturedImage == null
                      ? null
                      : () => context.go('/preferences'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}