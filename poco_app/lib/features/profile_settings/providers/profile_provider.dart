import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/user_profile.dart';

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final api = ref.watch(profileApiProvider);
  try {
    return await api.getProfile();
  } catch (_) {
    return null;
  }
});

final profileNameProvider = StateProvider<String>((ref) => 'Alex');
final profileLevelProvider = StateProvider<int>((ref) => 7);

final profileStatsProvider = Provider<Map<String, dynamic>>((ref) => {
  'recipes': 42,
  'time': '18h',
  'xp': 1250,
});

final dietaryPrefProvider = StateProvider<bool>((ref) => false);
final mealPlanningPrefProvider = StateProvider<bool>((ref) => true);
final notificationsPrefProvider = StateProvider<bool>((ref) => true);
final isDarkModeProvider = StateProvider<bool>((ref) => false);

Future<void> syncProfileFromApi(Ref ref) async {
  final profile = await ref.read(profileProvider.future);
  if (profile == null) return;
  ref.read(profileNameProvider.notifier).state = profile.name;
  ref.read(profileLevelProvider.notifier).state = profile.level;
  ref.read(dietaryPrefProvider.notifier).state = profile.dietaryPref;
  ref.read(mealPlanningPrefProvider.notifier).state = profile.mealPlanningPref;
  ref.read(notificationsPrefProvider.notifier).state = profile.notificationsPref;
  ref.read(isDarkModeProvider.notifier).state = profile.darkMode;
}

Future<void> saveProfile(dynamic ref) async {
  final api = ref.read(profileApiProvider);
  final name = ref.read(profileNameProvider);
  await api.updateProfile({
    'name': name,
    'dietary_pref': ref.read(dietaryPrefProvider),
    'meal_planning_pref': ref.read(mealPlanningPrefProvider),
    'notifications_pref': ref.read(notificationsPrefProvider),
    'dark_mode': ref.read(isDarkModeProvider),
  });
  ref.invalidate(profileProvider);
}
