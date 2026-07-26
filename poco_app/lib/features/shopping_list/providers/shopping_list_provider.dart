import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';

class ShoppingItem {
  final String? id;
  final String name;
  final String quantity;
  final String category;
  final bool checked;

  ShoppingItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.checked = false,
  });

  ShoppingItem copyWith({String? id, String? name, String? quantity, String? category, bool? checked}) =>
      ShoppingItem(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        category: category ?? this.category,
        checked: checked ?? this.checked,
      );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name, 'quantity': quantity, 'category': category, 'checked': checked,
  };

  factory ShoppingItem.fromResponse(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'] as String,
    name: json['name'] as String,
    quantity: json['quantity'] as String? ?? '',
    category: json['category'] as String? ?? '',
    checked: json['checked'] as bool? ?? false,
  );
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>(
  (ref) => ShoppingListNotifier(ref),
);

class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  final Ref _ref;
  ShoppingListNotifier(this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final api = _ref.read(shoppingListApiProvider);
      final items = await api.listItems();
      state = items.map((e) => ShoppingItem.fromResponse({
        'id': e.id, 'name': e.name, 'quantity': e.quantity, 'category': e.category, 'checked': e.checked,
      })).toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> add(String name, {String quantity = '', String category = ''}) async {
    try {
      final api = _ref.read(shoppingListApiProvider);
      final created = await api.createItem(name, quantity: quantity, category: category);
      state = [
        ...state,
        ShoppingItem(
          id: created.id, name: created.name,
          quantity: created.quantity, category: created.category,
        ),
      ];
    } catch (_) {
    }
  }

  Future<void> toggle(String name) async {
    final item = state.firstWhere((i) => i.name == name);
    final api = _ref.read(shoppingListApiProvider);
    try {
      await api.updateItem(item.id!, {'checked': !item.checked});
      state = state
          .map((i) => i.name == name ? i.copyWith(checked: !i.checked) : i)
          .toList();
    } catch (_) {
    }
  }

  Future<void> remove(String id) async {
    try {
      final api = _ref.read(shoppingListApiProvider);
      await api.deleteItem(id);
      state = state.where((i) => i.id != id).toList();
    } catch (_) {
    }
  }
}
