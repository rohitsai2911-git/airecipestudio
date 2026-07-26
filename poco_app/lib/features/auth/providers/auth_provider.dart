import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider((_) => Supabase.instance.client);

final authLoadingProvider = StateProvider<bool>((_) => false);

final authErrorProvider = StateProvider<String?>((_) => null);

final signInProvider = Provider<void>((ref) {
  throw UnimplementedError('Use signInWithEmail');
});

final signUpProvider = Provider<void>((ref) {
  throw UnimplementedError('Use signUpWithEmail');
});

final signOutProvider = Provider((ref) => () async {
  await Supabase.instance.client.auth.signOut();
});

void signInWithEmail(WidgetRef ref, String email, String password) async {
  ref.read(authLoadingProvider.notifier).state = true;
  ref.read(authErrorProvider.notifier).state = null;
  try {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    ref.read(authErrorProvider.notifier).state = e.toString();
  } finally {
    ref.read(authLoadingProvider.notifier).state = false;
  }
}

void signUpWithEmail(WidgetRef ref, String email, String password, String name) async {
  ref.read(authLoadingProvider.notifier).state = true;
  ref.read(authErrorProvider.notifier).state = null;
  try {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  } catch (e) {
    ref.read(authErrorProvider.notifier).state = e.toString();
  } finally {
    ref.read(authLoadingProvider.notifier).state = false;
  }
}
