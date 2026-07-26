import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lgiymwlixcoqthmkxary.supabase.co',
    publishableKey: 'sb_publishable_3KdLrNZ9JMHBMjlbvOVWZg_SjOmfnjM',
  );
  runApp(const ProviderScope(child: PocoApp()));
}

class PocoApp extends ConsumerWidget {
  const PocoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Poco',
      theme: buildTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
