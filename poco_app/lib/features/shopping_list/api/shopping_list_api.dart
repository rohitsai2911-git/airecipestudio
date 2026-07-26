import '../../../core/api/api_client.dart';

class ShoppingItemResponse {
  final String id;
  final String name;
  final String quantity;
  final String category;
  final bool checked;

  ShoppingItemResponse({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.checked,
  });

  factory ShoppingItemResponse.fromJson(Map<String, dynamic> json) => ShoppingItemResponse(
    id: json['id'] as String,
    name: json['name'] as String,
    quantity: json['quantity'] as String? ?? '',
    category: json['category'] as String? ?? '',
    checked: json['checked'] as bool? ?? false,
  );
}

class ShoppingListApi {
  final ApiClient _client;
  ShoppingListApi(this._client);

  Future<List<ShoppingItemResponse>> listItems() async {
    final data = await _client.get('/shopping-list');
    return (data as List).map((e) => ShoppingItemResponse.fromJson(e)).toList();
  }

  Future<ShoppingItemResponse> createItem(String name, {String quantity = '', String category = ''}) async {
    final data = await _client.post('/shopping-list', body: {
      'name': name, 'quantity': quantity, 'category': category,
    });
    return ShoppingItemResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<ShoppingItemResponse> updateItem(String id, Map<String, dynamic> updates) async {
    final data = await _client.patch('/shopping-list/$id', body: updates);
    return ShoppingItemResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteItem(String id) async {
    await _client.delete('/shopping-list/$id');
  }
}
