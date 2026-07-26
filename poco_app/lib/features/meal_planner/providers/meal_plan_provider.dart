import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/meal_plan_entry.dart';
import '../../../core/models/meal_plan_request.dart';
import '../../../core/models/saved_recipe.dart';

final selectedDayProvider = StateProvider<int>((ref) => 0);

final weekDaysProvider = Provider<List<String>>((ref) =>
  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
);

final weekDatesProvider = Provider<List<String>>((ref) {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return List.generate(7, (i) {
    final d = monday.add(Duration(days: i));
    return d.day.toString().padLeft(2, '0');
  });
});

final weekStartDateProvider = Provider<String>((ref) {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
});

final weekEndDateProvider = Provider<String>((ref) {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final sunday = monday.add(const Duration(days: 6));
  return '${sunday.year}-${sunday.month.toString().padLeft(2, '0')}-${sunday.day.toString().padLeft(2, '0')}';
});

final mealPlanEntriesProvider = FutureProvider<List<MealPlanEntry>>((ref) async {
  final api = ref.watch(mealPlanApiProvider);
  final start = ref.watch(weekStartDateProvider);
  final end = ref.watch(weekEndDateProvider);
  return api.listSlots(start, end);
});

final mealPlanSlotsProvider = Provider<Map<String, Map<String, MealPlanEntry>>>((ref) {
  final entriesAsync = ref.watch(mealPlanEntriesProvider);
  return entriesAsync.whenData((entries) {
    final slots = <String, Map<String, MealPlanEntry>>{};
    for (final entry in entries) {
      slots.putIfAbsent(entry.planDate, () => {});
      slots[entry.planDate]![entry.slot] = entry;
    }
    return slots;
  }).valueOrNull ?? {};
});

final allRecipesForPlannerProvider = FutureProvider<List<SavedRecipe>>((ref) async {
  final api = ref.watch(recipesApiProvider);
  return api.listRecipes();
});

Future<void> upsertMealPlan(dynamic ref, String date, String slot, String recipeId) async {
  final api = ref.read(mealPlanApiProvider);
  await api.upsertSlot(MealPlanRequest(planDate: date, slot: slot, recipeId: recipeId));
  ref.invalidate(mealPlanEntriesProvider);
}

Future<void> deleteMealPlan(dynamic ref, String entryId) async {
  final api = ref.read(mealPlanApiProvider);
  await api.deleteSlot(entryId);
  ref.invalidate(mealPlanEntriesProvider);
}