import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/saved_recipe.dart';

final recipeIdProvider = StateProvider<String?>((ref) => null);

final recipeDetailProvider = FutureProvider<SavedRecipe?>((ref) async {
  final id = ref.watch(recipeIdProvider);
  if (id == null) return null;
  final api = ref.watch(recipesApiProvider);
  return api.getRecipe(id);
});

final servingsScaleProvider = StateProvider<int>((ref) => 1);
