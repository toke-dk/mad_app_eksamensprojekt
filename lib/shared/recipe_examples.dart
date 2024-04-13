import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';

class RecipesProvider extends ChangeNotifier {
  final List<Recipe> _recipes =
      recipeExamples.map((e) => Recipe.fromMap(e)).toList();

  List<Recipe> get getRecipes => _recipes;

  set addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }
}

final List<Map<String, dynamic>> recipeExamples = [
  {
    "name": "Chicken and Vegetable Stir-Fry",
    "description":
        "A delicious and nutritious stir-fry loaded with tender chicken and colorful vegetables, seasoned with savory sauces.",
    "durationInMins": 30,
    "ingredientsForRecipe": [
      "Kyllingebrystfileter (500g)",
      "Broccolibuketter (400g)",
      "Blomkålsbuketter (400g)",
      "Rød peberfrugt (1)",
      "Gul peberfrugt (1)",
      "Orange peberfrugt (1)",
      "Gulerødder (1 kop skiver)",
      "Løg (1 stk)",
      "Hvidløgsfed (4 stk)",
      "Vegetabilsk olie (2 spiseskefulde)",
      "Soya sauce (1/4 kop)",
      "Østers sauce (2 spiseskefulde, valgfrit)",
      "Majsstivelse (2 spiseskefulde)"
    ],
    "instructions": [
      "Prepare the chicken by cutting it into thin strips and seasoning with salt and pepper.",
      "Heat vegetable oil in a large skillet or wok over medium-high heat. Add the chicken strips and cook until browned and cooked through. Remove chicken and set aside.",
      "In the same skillet, add more oil if needed. Add minced garlic and sliced onion, cook until softened.",
      "Add broccoli, cauliflower, bell peppers, and carrots. Stir-fry until vegetables are tender-crisp.",
      "Return cooked chicken to the skillet with the vegetables.",
      "Mix soy sauce and oyster sauce (if using), pour over chicken and vegetables.",
      "Stir in cornstarch mixture and cook until sauce thickens.",
      "Serve hot over cooked rice or noodles."
    ],
    "ingredientsToBuy": [
      {
        "name": "Broccolibuketter",
        "quantity": 0.4,
        "unit": "kg",
        "price": 13.95,
        "category": "Grøntsager"
      },
      {
        "name": "Blomkålsbuketter",
        "quantity": 0.4,
        "unit": "kg",
        "price": 12.95,
        "category": "Grøntsager"
      },
      {
        "name": "Peberfrugter i forskellige farver",
        "quantity": 0.5,
        "unit": "kg",
        "price": 19.95,
        "category": "Grøntsager"
      },
      {
        "name": "Gulerødder i skiver",
        "quantity": 1.0,
        "unit": "kg",
        "price": 14.39,
        "category": "Grøntsager"
      },
      {
        "name": "Løg",
        "quantity": 1.0,
        "unit": "kg",
        "price": 8.95,
        "category": "Grøntsager"
      },
      {
        "name": "Kyllingebrystfilet",
        "quantity": 0.5,
        "unit": "kg",
        "price": 39.95,
        "category": "Kød & Fjerkræ"
      },
      {
        "name": "Soy sauce",
        "quantity": 0.25,
        "unit": "l",
        "price": 22.0,
        "category": "Kolonial"
      },
      {
        "name": "Vegetable oil",
        "quantity": 1.0,
        "unit": "l",
        "price": 14.0,
        "category": "Kolonial"
      },
      {
        "name": "Cornstarch",
        "quantity": 500,
        "unit": "g",
        "price": 10.0,
        "category": "Kolonial"
      },
      {
        "name": "Oyster sauce",
        "quantity": 250,
        "unit": "ml",
        "price": 15.0,
        "category": "Kolonial"
      }
    ]
  }
];
