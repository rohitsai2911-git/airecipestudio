import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentStep = 0;

  final _steps = [
    (Icons.auto_awesome_outlined, 'Welcome to a smarter kitchen', 'Poco uses intelligence to transform how you cook, from ingredient scanning to voice guidance.'),
    (Icons.document_scanner_outlined, 'AI Ingredient Scanning', 'Just point your camera at your fridge. Poco identifies what you have and suggests the perfect recipe instantly.'),
    (Icons.mic_none_outlined, 'Hands-Free Help', 'Keep your hands clean. Control instructions, ask for substitutions, and set timers using only your voice.'),
  ];

  void _nextStep(int step) => setState(() => _currentStep = step);
  void _finish() => context.go('/register');

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.containerPadding),
          child: Column(
            children: [
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: KeyedSubtree(
                  key: ValueKey(_currentStep),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 280, height: 280,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          boxShadow: const [AppShadows.onboardingCard],
                          border: Border.all(color: AppColors.outlineVariant.withAlpha(51)),
                        ),
                        child: Icon(step.$1, size: 64, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.stackLg),
                      Text(step.$2, textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.stackMd),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                        child: Text(step.$3, textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentStep < 2 ? () => _nextStep(_currentStep + 1) : _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackMd),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                    elevation: 0,
                  ),
                  child: Text(_currentStep < 2 ? 'Continue' : "Let's Cook",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24)),
                ),
              ),
              if (_currentStep > 0)
                TextButton(
                  onPressed: () => _nextStep(0),
                  child: Text('Back to Start',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
