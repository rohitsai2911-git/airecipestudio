import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final loading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.containerPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.stackLg),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppSpacing.stackMd),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.stackSm),
                  child: Text(error, style: const TextStyle(color: AppColors.error)),
                ),
              const SizedBox(height: AppSpacing.stackLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          ref.read(authErrorProvider.notifier).state = null;
                          try {
                            await Supabase.instance.client.auth.signInWithPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          } catch (e) {
                            ref.read(authErrorProvider.notifier).state = e.toString();
                          }
                        },
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Log in'),
                ),
              ),
              TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text("Don't have an account? Sign up")),
            ],
          ),
        ),
      ),
    );
  }
}
