import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/pages/onboarding_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/recipe_discovery/pages/discovery_page.dart';
import '../../features/recipe_library/pages/library_page.dart';
import '../../features/xp_achievements/pages/xp_page.dart';
import '../../features/profile_settings/pages/profile_page.dart';
import '../../features/ingredient_scanner/pages/scanner_page.dart';
import '../../features/preferences/pages/preferences_page.dart';
import '../../features/recipe_generation/pages/generation_page.dart';
import '../../features/recipe_detail/pages/recipe_detail_page.dart';
import '../../features/poco_chat/pages/chat_page.dart';
import '../../features/voice_cooking/pages/voice_page.dart';
import '../../features/cooking_completion/pages/completion_page.dart';
import '../../features/meal_planner/pages/meal_planner_page.dart';
import '../../features/shopping_list/pages/shopping_list_page.dart';
import '../../features/pantry/pages/pantry_page.dart';
import 'auth_guard.dart';
import 'adaptive_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = auth != null;
      final isOnAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/';

      if (!loggedIn && !isOnAuth) return '/onboarding';
      if (loggedIn && isOnAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => AdaptiveShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/discover', builder: (_, __) => const DiscoveryPage()),
          GoRoute(path: '/library', builder: (_, __) => const LibraryPage()),
          GoRoute(path: '/xp', builder: (_, __) => const XpPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),
      GoRoute(path: '/scan', builder: (_, __) => const ScannerPage()),
      GoRoute(path: '/preferences', builder: (_, __) => const PreferencesPage()),
      GoRoute(path: '/generate', builder: (_, __) => const GenerationPage()),
      GoRoute(path: '/recipes/:id', builder: (_, state) => RecipeDetailPage(recipeId: state.pathParameters['id']!)),
      GoRoute(path: '/chat/:sessionId', builder: (_, state) => ChatPage(sessionId: state.pathParameters['sessionId']!)),
      GoRoute(path: '/voice-cooking/:id', builder: (_, state) => VoicePage(recipeId: state.pathParameters['id']!)),
      GoRoute(path: '/complete/:id', builder: (_, state) => CompletionPage(recipeId: state.pathParameters['id']!)),
      GoRoute(path: '/meal-planner', builder: (_, __) => const MealPlannerPage()),
      GoRoute(path: '/shopping-list', builder: (_, __) => const ShoppingListPage()),
      GoRoute(path: '/pantry', builder: (_, __) => const PantryPage()),
    ],
  );
});
