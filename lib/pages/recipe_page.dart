import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mad_app_eksamensprojekt/models/recipe.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Opskrift"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                style: textTheme.titleLarge,
              ),
              Text(
                recipe.description,
                style: textTheme.labelMedium,
              ),
              Text(
                  "${recipe.instructions.length} steps, ${recipe.durationInMins} min."),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: recipe.ingredientsForRecipe.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                      "${recipe.ingredientsForRecipe[index].quantity} ${recipe.ingredientsForRecipe[index].unit} ${recipe.ingredientsForRecipe[index].name}"),
                ),
                shrinkWrap: true,
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: recipe.instructions.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text("${index + 1}. ${recipe.instructions[index]}"),
                ),
                shrinkWrap: true,
              ),
              Text("Total pris: ${recipe.getTotalPrice.roundToDouble()}")
            ],
          ),
        ),
      ),
    );
  }
}
