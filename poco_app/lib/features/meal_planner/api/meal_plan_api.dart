import '../../../core/api/api_client.dart';
import '../../../core/models/meal_plan_entry.dart';
import '../../../core/models/meal_plan_request.dart';

class MealPlanApi {
  final ApiClient _client;
  MealPlanApi(this._client);

  Future<MealPlanEntry> upsertSlot(MealPlanRequest req) async {
    final data = await _client.post('/meal-plans', body: req.toJson());
    return MealPlanEntry.fromJson(data as Map<String, dynamic>);
  }

  Future<List<MealPlanEntry>> listSlots(String startDate, String endDate) async {
    final data = await _client.get('/meal-plans', queryParams: {
      'start_date': startDate, 'end_date': endDate,
    });
    return (data as List).map((e) => MealPlanEntry.fromJson(e)).toList();
  }

  Future<void> deleteSlot(String id) async {
    await _client.delete('/meal-plans/$id');
  }
}
