import '../../../core/api/api_client.dart';
import '../../../core/models/completion_result.dart';

class XpApi {
  final ApiClient _client;
  XpApi(this._client);

  Future<CompletionResult> completeRecipe(String recipeId) async {
    final data = await _client.post('/completions', body: {'recipe_id': recipeId});
    return CompletionResult.fromJson(data as Map<String, dynamic>);
  }
}
