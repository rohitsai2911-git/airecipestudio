import 'ingredient.dart';
import 'step.dart';

class Dish {
  final String title;
  final String cuisine;
  final int cookTimeMinutes;
  final int servings;
  final List<Ingredient> ingredients;
  final List<Step> steps;
  final String imagePromptKey;
  Dish({required this.title, required this.cuisine, required this.cookTimeMinutes, required this.servings, required this.ingredients, required this.steps, required this.imagePromptKey});
  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
    title: json['title'] as String,
    cuisine: json['cuisine'] as String,
    cookTimeMinutes: json['cook_time_minutes'] as int,
    servings: json['servings'] as int,
    ingredients: (json['ingredients'] as List).map((e) => Ingredient.fromJson(e)).toList(),
    steps: (json['steps'] as List).map((e) => Step.fromJson(e)).toList(),
    imagePromptKey: json['image_prompt_key'] as String,
  );
  Map<String, dynamic> toJson() => {
    'title': title, 'cuisine': cuisine, 'cook_time_minutes': cookTimeMinutes,
    'servings': servings, 'ingredients': ingredients.map((e) => e.toJson()).toList(),
    'steps': steps.map((e) => e.toJson()).toList(), 'image_prompt_key': imagePromptKey,
  };
}
