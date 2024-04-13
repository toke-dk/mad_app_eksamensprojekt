import 'package:mad_app_eksamensprojekt/models/ingredient.dart';

class Recipe {
  String name;
  String description;
  int durationInMins;
  List<String> ingredientsForRecipe;
  List<String> instructions;
  List<Ingredient> ingredientsToBuy;

  Recipe(
      {required this.name,
      required this.description,
      required this.durationInMins,
      required this.ingredientsForRecipe,
      required this.instructions,
      required this.ingredientsToBuy});

  // To map: convert each field to a compatible map structure
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'durationInMins': durationInMins,
      'ingredientsForRecipe': ingredientsForRecipe,
      'instructions': instructions,
      'ingredientsToBuy':
          ingredientsToBuy.map((ingredient) => ingredient.toMap()).toList(),
    };
  }

  // From map: create a Recipe object from a map structure
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      name: map['name'] as String,
      description: map['description'] as String,
      durationInMins: map['durationInMins'] as int,
      ingredientsForRecipe: map['ingredientsForRecipe']?.cast<String>() ?? [],
      instructions: map['instructions']?.cast<String>() ?? [],
      ingredientsToBuy: (map['ingredientsToBuy'] as List<dynamic>?)
              ?.map((ingredientMap) =>
                  Ingredient.fromMap(ingredientMap as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  double get getTotalPrice => ingredientsToBuy.map((e) => e.price).toList().reduce((a, b) => a+b);
}

const _jsonFormatComment = '''
This is how the format for the recipe should be
{
"name": str
"description": str
"durationInMins": int
"ingredientsForRecipe": List<str>
"instructions": List<str>
"ingredientsToBuy": {"name": str, "quantity": double, "unit": str, "price": double,}
}
''';
