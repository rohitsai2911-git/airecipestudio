class PantryItem {
  final String id;
  final String userId;
  final String name;
  final String quantity;
  final String unit;
  final DateTime createdAt;

  PantryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    this.unit = '',
    required this.createdAt,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) => PantryItem(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    quantity: json['quantity'] as String? ?? '',
    unit: json['unit'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
