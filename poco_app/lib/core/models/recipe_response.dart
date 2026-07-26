import 'dish.dart';

class RecipeResponse {
  final List<Dish> dishes;
  RecipeResponse({required this.dishes});
  factory RecipeResponse.fromJson(Map<String, dynamic> json) => RecipeResponse(
    dishes: (json['dishes'] as List).map((e) => Dish.fromJson(e)).toList(),
  );
}
