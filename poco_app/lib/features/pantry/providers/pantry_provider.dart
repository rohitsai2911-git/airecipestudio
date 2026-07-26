import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/pantry_item.dart';

final pantryItemsProvider = FutureProvider<List<PantryItem>>((ref) async {
  final api = ref.watch(pantryApiProvider);
  return api.listItems();
});

Future<void> addPantryItem(dynamic ref, String name, {String quantity = '', String unit = ''}) async {
  final api = ref.read(pantryApiProvider);
  await api.addItem(name, quantity: quantity, unit: unit);
  ref.invalidate(pantryItemsProvider);
}

Future<void> removePantryItem(dynamic ref, String id) async {
  final api = ref.read(pantryApiProvider);
  await api.deleteItem(id);
  ref.invalidate(pantryItemsProvider);
}
