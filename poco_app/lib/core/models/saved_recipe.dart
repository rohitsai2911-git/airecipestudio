import 'dish.dart';

class SavedRecipe {
  final String id;
  final String userId;
  final Dish dish;
  final bool bookmarked;
  final String status;
  final DateTime createdAt;
  SavedRecipe({required this.id, required this.userId, required this.dish, required this.bookmarked, required this.status, required this.createdAt});
  factory SavedRecipe.fromJson(Map<String, dynamic> json) => SavedRecipe(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    dish: Dish.fromJson(json['dish'] as Map<String, dynamic>),
    bookmarked: json['bookmarked'] as bool,
    status: json['status'] as String? ?? 'saved',
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
