import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import '../../ingredient_scanner/providers/scanner_provider.dart';
import '../../preferences/providers/preferences_provider.dart';

enum GenerationStatus { idle, generating, success, error }

class GenerationState {
  final GenerationStatus status;
  final String? errorMessage;
  final int savedCount;

  const GenerationState({this.status = GenerationStatus.idle, this.errorMessage, this.savedCount = 0});
}

final generationProvider = StateNotifierProvider<GenerationNotifier, GenerationState>((ref) {
  return GenerationNotifier(ref);
});

class GenerationNotifier extends StateNotifier<GenerationState> {
  final Ref _ref;
  GenerationNotifier(this._ref) : super(const GenerationState());

  Future<void> generate() async {
    state = const GenerationState(status: GenerationStatus.generating);
    try {
      final api = _ref.read(recipesApiProvider);
      final ingredients = _ref.read(scannedIngredientsProvider);
      final imageBase64 = _ref.read(capturedImageProvider);
      final prefs = _ref.read(preferencesProvider);

      final response = await api.generateRecipes(
        ingredients: ingredients,
        imageBase64: imageBase64,
        cuisine: prefs.cuisine,
        servingSize: prefs.servings,
        timeLimitMinutes: prefs.timeLimitMinutes,
      );

      int saved = 0;
      for (final dish in response.dishes) {
        final savedRecipe = await api.saveRecipe(dish.toJson());
        saved++;
        try {
          final imageBase64 = await api.generateImage(savedRecipe.id, dish.imagePromptKey);
          _ref.read(recipeImageCacheProvider.notifier).setImage(savedRecipe.id, imageBase64);
        } catch (_) {
        }
      }

      state = GenerationState(status: GenerationStatus.success, savedCount: saved);
    } catch (e) {
      state = GenerationState(status: GenerationStatus.error, errorMessage: e.toString());
    }
  }

  void reset() => state = const GenerationState();
}