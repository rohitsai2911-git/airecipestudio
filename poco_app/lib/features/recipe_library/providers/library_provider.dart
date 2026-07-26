import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/saved_recipe.dart';

final librarySearchQuery = StateProvider<String>((ref) => '');
final libraryFilterProvider = StateProvider<String>((ref) => 'All');

final libraryRecipesProvider = FutureProvider<List<SavedRecipe>>((ref) async {
  final api = ref.watch(recipesApiProvider);
  final filter = ref.watch(libraryFilterProvider);
  bool? bookmarked;
  if (filter == 'Favorites') bookmarked = true;
  return api.listRecipes(bookmarked: bookmarked);
});
