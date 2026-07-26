class MealPlanEntry {
  final String id;
  final String userId;
  final String planDate;
  final String slot;
  final String recipeId;
  final DateTime createdAt;
  MealPlanEntry({required this.id, required this.userId, required this.planDate, required this.slot, required this.recipeId, required this.createdAt});
  factory MealPlanEntry.fromJson(Map<String, dynamic> json) => MealPlanEntry(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    planDate: json['plan_date'] as String,
    slot: json['slot'] as String,
    recipeId: json['recipe_id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
