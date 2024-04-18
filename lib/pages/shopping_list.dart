import 'package:flutter/material.dart';
import 'package:mad_app_eksamensprojekt/models/ingredient.dart';
import 'package:mad_app_eksamensprojekt/providers/recipes_provider.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});



  @override
  Widget build(BuildContext context) {

    final List<Recipe> recipes = context.read<RecipesProvider>().getRecipes;


    print("gathered ${recipes.gatheredIngredients.getngredientsNameLowerCase}");

    return Scaffold(
      appBar: AppBar(title: Text("Inkøbsliste"),),
      body: Column(
        children: [
          ExpansionPanelList(
            children: [
              ExpansionPanel(headerBuilder: (context, _){
                return Text("data");
              }, body: Text("open"))
            ],
          ),
          Text("Indkøbsliste"),
          Text(recipes.gatheredIngredients.getngredientsNameLowerCase.toString()),
          Text("Estimeret pris for alle ingredienser:"),
          Text(recipes.getRecipesPrice.toString())
        ],
      ),
    );
  }
}
