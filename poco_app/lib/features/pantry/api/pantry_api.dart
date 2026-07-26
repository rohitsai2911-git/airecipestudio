import '../../../core/api/api_client.dart';
import '../../../core/models/pantry_item.dart';

class PantryApi {
  final ApiClient _client;
  PantryApi(this._client);

  Future<List<PantryItem>> listItems() async {
    final data = await _client.get('/pantry');
    return (data as List).map((e) => PantryItem.fromJson(e)).toList();
  }

  Future<PantryItem> addItem(String name, {String quantity = '', String unit = ''}) async {
    final data = await _client.post('/pantry', body: {
      'name': name, 'quantity': quantity, 'unit': unit,
    });
    return PantryItem.fromJson(data as Map<String, dynamic>);
  }

  Future<PantryItem> updateItem(String id, Map<String, dynamic> updates) async {
    final data = await _client.patch('/pantry/$id', body: updates);
    return PantryItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteItem(String id) async {
    await _client.delete('/pantry/$id');
  }
}
