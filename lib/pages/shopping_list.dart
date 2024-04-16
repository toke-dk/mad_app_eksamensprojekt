import 'package:flutter/material.dart';
import 'package:mad_app_eksamensprojekt/providers/recipes_provider.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});



  @override
  Widget build(BuildContext context) {

    final List<Recipe> recipes = context.read<RecipesProvider>().getRecipes;

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
          )
        ],
      ),
    );
  }
}
