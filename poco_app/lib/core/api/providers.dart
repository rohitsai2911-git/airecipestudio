import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import '../../features/recipes/api/recipes_api.dart';
import '../../features/meal_planner/api/meal_plan_api.dart';
import '../../features/xp_achievements/api/xp_api.dart';
import '../../features/poco_chat/api/chat_api.dart';
import '../../features/profile_settings/api/profile_api.dart';
import '../../features/shopping_list/api/shopping_list_api.dart';
import '../../features/pantry/api/pantry_api.dart';

const _defaultBaseUrl = 'http://127.0.0.1:8000';

final apiBaseUrlProvider = Provider<String>((ref) => _defaultBaseUrl);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(apiBaseUrlProvider));
});

final recipesApiProvider = Provider<RecipesApi>((ref) {
  return RecipesApi(ref.watch(apiClientProvider));
});

final mealPlanApiProvider = Provider<MealPlanApi>((ref) {
  return MealPlanApi(ref.watch(apiClientProvider));
});

final xpApiProvider = Provider<XpApi>((ref) {
  return XpApi(ref.watch(apiClientProvider));
});

final chatApiProvider = Provider<ChatApi>((ref) {
  return ChatApi(ref.watch(apiClientProvider));
});

final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ref.watch(apiClientProvider));
});

final shoppingListApiProvider = Provider<ShoppingListApi>((ref) {
  return ShoppingListApi(ref.watch(apiClientProvider));
});

final pantryApiProvider = Provider<PantryApi>((ref) {
  return PantryApi(ref.watch(apiClientProvider));
});

final recipeImageCacheProvider = StateNotifierProvider<RecipeImageCacheNotifier, Map<String, String>>((ref) {
  return RecipeImageCacheNotifier();
});

class RecipeImageCacheNotifier extends StateNotifier<Map<String, String>> {
  RecipeImageCacheNotifier() : super({});

  void setImage(String recipeId, String base64) {
    state = {...state, recipeId: base64};
  }

  String? getImage(String recipeId) => state[recipeId];
}
