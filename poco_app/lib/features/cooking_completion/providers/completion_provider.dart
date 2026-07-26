import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/completion_result.dart';
import '../../xp_achievements/providers/xp_provider.dart';

final xpAnimationComplete = StateProvider<bool>((ref) => false);
final completionResultProvider = StateProvider<CompletionResult?>((ref) => null);
final isCompletingProvider = StateProvider<bool>((ref) => true);
final completionErrorProvider = StateProvider<String?>((ref) => null);

Future<void> completeRecipe(dynamic ref, String recipeId) async {
  ref.read(isCompletingProvider.notifier).state = true;
  ref.read(completionErrorProvider.notifier).state = null;
  try {
    final api = ref.read(xpApiProvider);
    final result = await api.completeRecipe(recipeId);
    ref.read(completionResultProvider.notifier).state = result;
    applyCompletion(ref, result);
    ref.read(xpAnimationComplete.notifier).state = false;
  } catch (e) {
    ref.read(completionErrorProvider.notifier).state = e.toString();
  } finally {
    ref.read(isCompletingProvider.notifier).state = false;
  }
}
