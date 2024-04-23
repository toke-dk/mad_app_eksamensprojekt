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

    for (Ingredient indexIngredient in allIngredients) {
      Ingredient? equalIngredient = ingredientsToReturn.where(
          (n) => n.name.toLowerCase() == indexIngredient.name.toLowerCase()).firstOrNull;

      if (equalIngredient != null &&
          equalIngredient.unit.toLowerCase() ==
              indexIngredient.unit.toLowerCase()) {
        print(
            "again: ${indexIngredient == equalIngredient}, old: ${equalIngredient.quantity}, new ${indexIngredient.quantity} = ${equalIngredient.quantity + indexIngredient.quantity}");

        int index = ingredientsToReturn.getngredientsNameLowerCase
            .indexOf(indexIngredient.name.toLowerCase());

        ingredientsToReturn.replaceRange(index, index + 1, [
          Ingredient(
              name: equalIngredient.name,
              quantity: equalIngredient.quantity + indexIngredient.quantity,
              unit: equalIngredient.unit,
              price: equalIngredient.price)
        ]);

        //print("returner ${ingredientsToReturn.map((e) => e.toMap())}");
      } else {
        ingredientsToReturn.add(indexIngredient);
      }
    }

    return ingredientsToReturn;
  }
}
