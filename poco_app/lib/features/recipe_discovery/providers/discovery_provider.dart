import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/saved_recipe.dart';

final activeFilterProvider = StateProvider<String>((ref) => 'All Recipes');

final discoveryRecipesProvider = FutureProvider<List<SavedRecipe>>((ref) async {
  final api = ref.watch(recipesApiProvider);
  return api.listRecipes();
});