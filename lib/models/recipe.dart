import 'package:mad_app_eksamensprojekt/models/ingredient.dart';

class Recipe {
  String name;
  String description;
  int durationInMins;
  List<Ingredient> ingredientsForRecipe;
  List<String> instructions;

  Recipe({
    required this.name,
    required this.description,
    required this.durationInMins,
    required this.ingredientsForRecipe,
    required this.instructions,
  });

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
    print("map: ${map}");
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

  double get getTotalPrice => ingredientsForRecipe.getTotalPrice;
}

extension RecipesExtension on List<Recipe> {
  double get getRecipesPrice =>
      map((e) => e.getTotalPrice).reduce((value, element) => value + element);

  List<Ingredient> get getAllIngredients =>
      map((e) => e.ingredientsForRecipe).expand((element) => element).toList();

  List<Ingredient> get gatheredIngredients {
    List<Ingredient> ingredientsToReturn = [];

    List<Ingredient> allIngredients = getAllIngredients;

    for (Ingredient ingredient in allIngredients) {
      Ingredient? equalIngredient =
          ingredientsToReturn.getngredientsNameLowerCase.contains(ingredient.name.toLowerCase())
              ? ingredient
              : null;

      if (equalIngredient != null &&
          equalIngredient.unit.toLowerCase() == ingredient.unit.toLowerCase()) {
        equalIngredient.quantity += ingredient.quantity;
        //print("returner ${ingredientsToReturn.getngredientsName}");
      } else {
        ingredientsToReturn.add(ingredient);
      }
    }

    return ingredientsToReturn;
  }
}
