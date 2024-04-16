import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../shared/recipe_examples.dart';

class RecipesProvider extends ChangeNotifier {
  final List<Recipe> _recipes =
  recipeExamples.map((e) => Recipe.fromMap(e)).toList();

  List<Recipe> get getRecipes => _recipes;

  set addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }

  set addAllRecipes(List<Recipe> recipes) {
    _recipes.addAll(recipes);
    notifyListeners();
  }

  void removeRecipe(Recipe recipe) {
    _recipes.remove(recipe);
    notifyListeners();
  }

  void replaceRecipe(Recipe recipeToReplace, Recipe newRecipe) {
    if (!_recipes.contains(recipeToReplace)) return;
    int index = _recipes.indexOf(recipeToReplace);
    _recipes[index] = newRecipe;
    notifyListeners();
  }
}