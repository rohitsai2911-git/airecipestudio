class Ingredient {
  final String name;
  final String quantity;
  final String unit;
  Ingredient({required this.name, required this.quantity, this.unit = ''});
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    name: json['name'] as String,
    quantity: json['quantity'] as String,
    unit: json['unit'] as String? ?? '',
  );
  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity, 'unit': unit};
}
