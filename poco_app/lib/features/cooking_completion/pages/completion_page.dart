import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/design_system/widgets/tactile_button.dart';
import '../../../core/models/completion_result.dart';
import '../providers/completion_provider.dart';
import '../widgets/xp_animation.dart';
import '../widgets/confetti_overlay.dart';

class CompletionPage extends ConsumerStatefulWidget {
  final String recipeId;

  const CompletionPage({super.key, required this.recipeId});

  @override
  ConsumerState<CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends ConsumerState<CompletionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      completeRecipe(ref, widget.recipeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCompleting = ref.watch(isCompletingProvider);
    final error = ref.watch(completionErrorProvider);
    final result = ref.watch(completionResultProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Cooking Complete!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.stackLg),
              const XpAnimation(),
              const SizedBox(height: AppSpacing.stackMd),
              const ConfettiOverlay(),
              const SizedBox(height: AppSpacing.stackLg),
              isCompleting
                  ? const CircularProgressIndicator()
                  : error != null
                      ? Text('Error: $error', style: const TextStyle(color: AppColors.error))
                      : _buildXpCard(context, result),
              const SizedBox(height: AppSpacing.stackLg),
              _buildShareRow(context),
              const SizedBox(height: AppSpacing.stackLg),
              TactileButton(
                text: 'Back to Home',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildXpCard(BuildContext context, CompletionResult? result) {
    final xpAwarded = result?.xpAwarded ?? 150;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [AppShadows.card],
      ),
      child: Text(
        'You earned $xpAwarded XP!',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildShareRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _shareButton(context, Icons.share),
        const SizedBox(width: AppSpacing.stackMd),
        _shareButton(context, Icons.alternate_email),
        const SizedBox(width: AppSpacing.stackMd),
        _shareButton(context, Icons.message),
      ],
    );
  }

  Widget _shareButton(BuildContext context, IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.onSurfaceVariant),
        onPressed: () {},
      ),
    );
  }
}
