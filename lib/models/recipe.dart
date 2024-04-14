import 'package:mad_app_eksamensprojekt/models/ingredient.dart';

class Recipe {
  String name;
  String description;
  int durationInMins;
  List<Ingredient> ingredientsForRecipe;
  List<String> instructions;

  Recipe(
      {required this.name,
      required this.description,
      required this.durationInMins,
      required this.ingredientsForRecipe,
      required this.instructions,});

  // To map: convert each field to a compatible map structure
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'durationInMins': durationInMins,
      'ingredientsForRecipe':
      ingredientsForRecipe.map((ingredient) => ingredient.toMap()).toList(),
      'instructions': instructions,

    };
  }

  // From map: create a Recipe object from a map structure
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      name: map['name'] as String,
      description: map['description'] as String,
      durationInMins: map['durationInMins'] as int,
      ingredientsForRecipe: (map['ingredientsForRecipe'] as List<dynamic>?)
          ?.map((ingredientMap) =>
          Ingredient.fromMap(ingredientMap as Map<String, dynamic>))
          .toList() ??
          [],
      instructions: map['instructions']?.cast<String>() ?? [],

    );
  }

  double get getTotalPrice => ingredientsForRecipe.map((e) => e.price).toList().reduce((a, b) => a+b);
}

