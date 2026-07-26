import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(_controller);
    Future.delayed(const Duration(milliseconds: 2500), () {
      _controller.forward().then((_) => context.go('/home'));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FadeTransition(
        opacity: _fadeOut,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 128, height: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [AppShadows.card],
                  color: AppColors.primaryContainer,
                ),
                child: const Icon(Icons.restaurant, size: 64, color: AppColors.onPrimaryContainer),
              ),
              const SizedBox(height: 32),
              Text('Poco', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 8),
              Text('Your AI Sous-Chef', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
