import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recipe.dart';
import '../../pages/recipe_page.dart';
import '../../providers/recipes_provider.dart';
import 'my_value_changer.dart';

class DisplayRecipe extends StatelessWidget {
  const DisplayRecipe(
      {super.key,
      this.onRecipePressed,
      this.onRefreshPressed,
      required this.recipe});

  final Function()? onRecipePressed;
  final Function()? onRefreshPressed;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: onRefreshPressed == null
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: onRefreshPressed,
                ),
          onTap: onRecipePressed,
          title: Text("${recipe.name}"),
          subtitle: Text(
              "${recipe.durationInMins} minutter, ${recipe.ingredientsForRecipe.length} ingredienser,  ${recipe.getTotalPrice.roundToDouble()} .-"),
        ),
        Container(
            padding: const EdgeInsets.only(left: 20),
            height: 40,
            child: FittedBox(
              child: MyValueChanger(
                  handleValueChange: (int newVal) {
                    Provider.of<RecipesProvider>(context, listen: false)
                        .changeRecipeAmounts(recipe, newVal);
                  },
                  value: recipe.amounts),
            )),
      ],
    );
  }
}
