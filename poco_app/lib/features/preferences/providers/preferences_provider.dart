import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreferencesState {
  final String cuisine;
  final String difficulty;
  final int timeLimitMinutes;
  final int servings;

  const PreferencesState({
    this.cuisine = 'any',
    this.difficulty = 'beginner',
    this.timeLimitMinutes = 30,
    this.servings = 2,
  });

  PreferencesState copyWith({String? cuisine, String? difficulty, int? timeLimitMinutes, int? servings}) {
    return PreferencesState(
      cuisine: cuisine ?? this.cuisine,
      difficulty: difficulty ?? this.difficulty,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      servings: servings ?? this.servings,
    );
  }
}

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
  return PreferencesNotifier();
});

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier() : super(const PreferencesState());

  void setCuisine(String c) => state = state.copyWith(cuisine: c);
  void setDifficulty(String d) => state = state.copyWith(difficulty: d);
  void setTimeLimit(int t) => state = state.copyWith(timeLimitMinutes: t);
  void setServings(int s) => state = state.copyWith(servings: s);
}
