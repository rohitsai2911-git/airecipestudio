import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/poco_mascot_tip.dart';
import '../providers/voice_provider.dart';
import '../widgets/voice_step_display.dart';
import '../widgets/voice_controls.dart';

class VoicePage extends ConsumerStatefulWidget {
  final String recipeId;

  const VoicePage({super.key, required this.recipeId});

  @override
  ConsumerState<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends ConsumerState<VoicePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAndPlayRecipe(ref, widget.recipeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(voiceRecipeProvider(widget.recipeId));
    final currentStep = ref.watch(currentStepProvider);
    final isSpeaking = ref.watch(isSpeakingProvider);
    final isPaused = ref.watch(isPausedProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: recipeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (recipe) {
            if (recipe == null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Column(
                  children: [
                    _buildHeader(context, false, false),
                    const Spacer(),
                    const Text('Recipe not found'),
                    const Spacer(),
                  ],
                ),
              );
            }
            final steps = recipe.dish.steps;
            final stepIndex = currentStep.clamp(0, steps.length - 1);
            final step = steps[stepIndex];
            final totalSteps = steps.length;

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.containerPadding),
              child: Column(
                children: [
                  _buildHeader(context, isSpeaking, isPaused),
                  const SizedBox(height: AppSpacing.stackLg),
                  Text(
                    recipe.dish.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Expanded(
                    child: VoiceStepDisplay(
                      stepNumber: step.number,
                      title: step.instruction.length > 50
                          ? '${step.instruction.substring(0, 47)}...'
                          : step.instruction,
                      description: step.instruction,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Text('Step ${stepIndex + 1} of $totalSteps'),
                  const SizedBox(height: AppSpacing.stackMd),
                  const PocoMascotTip(
                    tip: 'Try saying "next step" or "repeat that" hands-free!',
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  VoiceControls(
                    onRepeat: () async {
                      await stopAudio(ref);
                      await loadAndPlayRecipe(ref, widget.recipeId);
                    },
                    onNext: () {
                      if (stepIndex + 1 < totalSteps) {
                        ref.read(currentStepProvider.notifier).state = stepIndex + 1;
                      } else {
                        context.go('/complete/${widget.recipeId}');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSpeaking, bool isPaused) {
    return Row(
      children: [
        Text(
          'Voice Mode',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const Spacer(),
        if (isSpeaking)
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () => togglePlayPause(ref),
          ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ],
    );
  }
}
