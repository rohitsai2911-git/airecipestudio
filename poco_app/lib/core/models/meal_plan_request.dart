class MealPlanRequest {
  final String planDate;
  final String slot;
  final String recipeId;
  MealPlanRequest({required this.planDate, required this.slot, required this.recipeId});
  Map<String, dynamic> toJson() => {'plan_date': planDate, 'slot': slot, 'recipe_id': recipeId};
}
