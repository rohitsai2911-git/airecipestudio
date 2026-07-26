import 'dart:typed_data';
import '../../../core/api/api_client.dart';
import '../../../core/models/recipe_response.dart';
import '../../../core/models/saved_recipe.dart';

class RecipesApi {
  final ApiClient _client;
  RecipesApi(this._client);

  Future<RecipeResponse> generateRecipes({
    required List<String> ingredients,
    String? imageBase64,
    String cuisine = 'any',
    required int servingSize,
    int? timeLimitMinutes,
  }) async {
    final data = await _client.post('/recipes/generate', body: {
      'ingredients': ingredients,
      if (imageBase64 != null) 'ingredient_image_base64': imageBase64,
      'cuisine': cuisine,
      'serving_size': servingSize,
      if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
    });
    return RecipeResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<SavedRecipe> saveRecipe(Map<String, dynamic> dish) async {
    final data = await _client.post('/recipes', body: {'dish': dish});
    return SavedRecipe.fromJson(data as Map<String, dynamic>);
  }

  Future<List<SavedRecipe>> listRecipes({bool? bookmarked}) async {
    final data = await _client.get('/recipes', queryParams: bookmarked != null ? {'bookmarked': bookmarked.toString()} : null);
    return (data as List).map((e) => SavedRecipe.fromJson(e)).toList();
  }

  Future<SavedRecipe> getRecipe(String id) async {
    final data = await _client.get('/recipes/$id');
    return SavedRecipe.fromJson(data as Map<String, dynamic>);
  }

  Future<SavedRecipe> setBookmark(String id, bool bookmarked) async {
    final data = await _client.patch('/recipes/$id/bookmark', body: {'bookmarked': bookmarked});
    return SavedRecipe.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteRecipe(String id) async {
    await _client.delete('/recipes/$id');
  }

  Future<String> generateImage(String recipeId, String prompt) async {
    final data = await _client.post('/recipes/$recipeId/image', body: {
      'prompt': prompt,
      'model': '@cf/black-forest-labs/flux-1-schnell',
    });
    return (data as Map<String, dynamic>)['image_base64'] as String;
  }

  Future<Uint8List> speakRecipe(String recipeId) async {
    return _client.postBinary('/recipes/$recipeId/speak');
  }
}
