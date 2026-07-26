class CompletionResult {
  final String recipeId;
  final int xp;
  final int level;
  final int xpAwarded;
  CompletionResult({required this.recipeId, required this.xp, required this.level, required this.xpAwarded});
  factory CompletionResult.fromJson(Map<String, dynamic> json) => CompletionResult(
    recipeId: json['recipe_id'] as String,
    xp: json['xp'] as int,
    level: json['level'] as int,
    xpAwarded: json['xp_awarded'] as int,
  );
}
