import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/saved_recipe.dart';

final currentStepProvider = StateProvider<int>((ref) => 0);
final isListeningProvider = StateProvider<bool>((ref) => false);
final isSpeakingProvider = StateProvider<bool>((ref) => false);
final isPausedProvider = StateProvider<bool>((ref) => false);

final voiceRecipeProvider = FutureProvider.family<SavedRecipe?, String>((ref, recipeId) async {
  final api = ref.watch(recipesApiProvider);
  try {
    return await api.getRecipe(recipeId);
  } catch (_) {
    return null;
  }
});

final totalStepsProvider = Provider.family<int, SavedRecipe?>((ref, recipe) {
  if (recipe == null) return 0;
  return recipe.dish.steps.length;
});

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

Future<void> loadAndPlayRecipe(dynamic ref, String recipeId) async {
  final api = ref.read(recipesApiProvider);
  final player = ref.read(audioPlayerProvider);
  try {
    ref.read(isSpeakingProvider.notifier).state = true;
    final audioBytes = await api.speakRecipe(recipeId);
    final source = BytesSource(Uint8List.fromList(audioBytes));
    await player.play(source);
    player.onPlayerComplete.listen((_) {
      ref.read(isSpeakingProvider.notifier).state = false;
    });
  } catch (_) {
    ref.read(isSpeakingProvider.notifier).state = false;
  }
}

Future<void> togglePlayPause(dynamic ref) async {
  final player = ref.read(audioPlayerProvider);
  if (ref.read(isPausedProvider)) {
    await player.resume();
    ref.read(isPausedProvider.notifier).state = false;
  } else {
    await player.pause();
    ref.read(isPausedProvider.notifier).state = true;
  }
}

Future<void> stopAudio(dynamic ref) async {
  final player = ref.read(audioPlayerProvider);
  await player.stop();
  ref.read(isSpeakingProvider.notifier).state = false;
  ref.read(isPausedProvider.notifier).state = false;
}
