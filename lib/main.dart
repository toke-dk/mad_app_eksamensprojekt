import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:mad_app_eksamensprojekt/models/recipe.dart';
import 'package:mad_app_eksamensprojekt/providers/recipes_provider.dart';
import 'package:mad_app_eksamensprojekt/shared/all_ingredients.dart';
import 'package:mad_app_eksamensprojekt/shared/recipe_examples.dart';
import 'package:provider/provider.dart';

import 'env/env.dart';
import 'models/ingredient.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
          create: (context) => RecipesProvider(),
          child: const MyHomePage(title: 'Teknologi Årsprojekt')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Ingredient> get ingredients => recipes.first.ingredientsToBuy;

  List<Recipe> get recipes => Provider.of<RecipesProvider>(context).getRecipes;

  OpenAIChatCompletionModel? content;

  @override
  Widget build(BuildContext context) {
    print(Provider.of<RecipesProvider>(context).getRecipes.map((e) => e.name));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final Recipe currentRecipe = recipes[index];
                  return ListTile(
                    title: Text(currentRecipe.name),
                    trailing: Text(
                        "${currentRecipe.getTotalPrice.roundToDouble()} .-"),
                    subtitle: Text(
                        "${currentRecipe.durationInMins} minutter, ${currentRecipe.ingredientsToBuy.length} ingredienser"),
                  );
                }),
            OutlinedButton(
                onPressed: () {
                  Provider.of<RecipesProvider>(context, listen: false)
                      .addRecipe = Recipe.fromMap(recipeExamples.first);
                },
                child: Text("Add exampleIngredient")),
            OutlinedButton(
                onPressed: () async {
                  final response = await _apiExample();
                  setState(() {
                    content = response;
                  });
                  print(jsonDecode(
                      response!.choices.first.message.content!.first.text!));
                },
                child: const Text("Skab ret")),
            OutlinedButton(
                onPressed: () {
                  // print(content!.choices.first.message.toString().substring(900,content!.choices.first.message.toString().length));
                  Recipe recipeFromAi = Recipe.fromMap(jsonDecode(
                      content!.choices.first.message.content!.first.text!));
                  print(recipeFromAi);
                  Provider.of<RecipesProvider>(context, listen: false)
                      .addRecipe = recipeFromAi;

                  print(recipeFromAi.ingredientsForRecipe);
                },
                child: Text("debug print"))
          ],
        ),
      ),
    );
  }
}

Future<OpenAIChatCompletionModel> _apiExample() async {
  OpenAI.apiKey = Env.apiKey;
  // the system message that will be sent to the request.
  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        ''' retuner hvilken givet besked som dette JSON-format:
          {
            "name": TEXT,
            "description": TEXT,
            "durationInMins": INTEGER,
            "ingredientsForRecipe": List<TEXT>,
            "instructions": List<TEXT>,
            "ingredientsToBuy": List<{"name": TEXT, "quantity": DOUBLE, "unit": STRING, "price": DOUBLE,}>
          }
        ''',
      ),
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "Hvor 'ingredientsForRecipe' beskriver hvor meget af en ingrediens der bliver brugt i opskriften",
      ),
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "Hvor 'ingredientsToBuy' er de ingredienser der bliver brugt i opsrkiften (grøntsager, kød, dåser osv.) bare formateret på denne måde",
      ),
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "opskriften skal være på dansk",
      ),
    ],
    role: OpenAIChatMessageRole.assistant,
  );

  // the user message that will be sent to the request.
  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "Lav en aftensmadsret. Du må bruge nogle disse ingredienser ${kSampleIngredients.map((e) => e.toMap())} ikke andre",
      ),
    ],
    role: OpenAIChatMessageRole.user,
  );

// all messages to be sent.
  final requestMessages = [
    systemMessage,
    userMessage,
  ];

// the actual request.
  OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
    model: "gpt-3.5-turbo-1106",
    responseFormat: {"type": "json_object"},
    seed: 6,
    messages: requestMessages,
    temperature: 0.2,
    maxTokens: 700,
  );

  return chatCompletion;
}
