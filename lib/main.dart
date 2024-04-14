import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:mad_app_eksamensprojekt/models/recipe.dart';
import 'package:mad_app_eksamensprojekt/pages/recipe_page.dart';
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
  bool onlyVegitarian = false;
  bool onlyVegan = false;
  bool noLactose = false;
  bool noGluten = false;

  List<String> get generateRestrictions {
    List<String> restrictions = [];
    if (onlyVegitarian) restrictions.add("vegetar");
    if (onlyVegan) restrictions.add("vegansk");
    if (noLactose) restrictions.add("laktosefrit");
    if (noGluten) restrictions.add("glutenfrit");
    return restrictions;
  }

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
            CheckboxListTile(
                title: Text("Vegetar"),
                value: onlyVegitarian,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    onlyVegitarian = val;
                  });
                }),
            CheckboxListTile(
                title: Text("Vegansk"),
                value: onlyVegan,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    onlyVegan = val;
                  });
                }),
            CheckboxListTile(
                title: Text("Laktosefri"),
                value: noLactose,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    noLactose = val;
                  });
                }),
            CheckboxListTile(
                title: Text("Glutenfri"),
                value: noGluten,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    noGluten = val;
                  });
                }),
            OutlinedButton(
                onPressed: () async {
                  final response = await _apiExample(["vegetar"]);
                  setState(() {
                    content = response;
                  });
                  // print(content!.choices.first.message.toString().substring(900,content!.choices.first.message.toString().length));
                  Recipe recipeFromAi = Recipe.fromMap(jsonDecode(
                      content!.choices.first.message.content!.first.text!));
                  Provider.of<RecipesProvider>(context, listen: false)
                      .addRecipe = recipeFromAi;

                  print(jsonDecode(
                      response!.choices.first.message.content!.first.text!));
                },
                child: const Text("Skab ret")),
            Divider(),
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final Recipe indexRecipe = recipes[index];
                  return ListTile(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RecipePage(recipe: indexRecipe))),
                    title: Text(indexRecipe.name),
                    trailing:
                        Text("${indexRecipe.getTotalPrice.roundToDouble()} .-"),
                    subtitle: Text(
                        "${indexRecipe.durationInMins} minutter, ${indexRecipe.ingredientsToBuy.length} ingredienser"),
                  );
                }),
            OutlinedButton(
                onPressed: () {
                  Provider.of<RecipesProvider>(context, listen: false)
                      .addRecipe = Recipe.fromMap(recipeExamples.first);
                },
                child: Text("Add exampleIngredient")),
            OutlinedButton(
                onPressed: () {
                  Recipe recipeFromAi = Recipe.fromMap(jsonDecode(
                      content!.choices.first.message.content!.first.text!));

                  print(recipeFromAi.ingredientsToBuy.map((e) => e.name));
                  print(recipeFromAi.ingredientsForRecipe);
                  print(recipeFromAi.ingredientsToBuy.map((e) => e.quantity));
                },
                child: Text("debug print"))
          ],
        ),
      ),
    );
  }
}

Future<OpenAIChatCompletionModel> _apiExample(List<String> requirements) async {
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
        "ingredientsToBuy skal have de samme ingredienser/elemnter/madvarer som ingredientsForRecipe",
      ),
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "opskriften skal være på dansk",
      ),
    ],
    role: OpenAIChatMessageRole.assistant,
  );

  // shuffiling ingredients, to get better results
  kSampleIngredients.shuffle();

  // the user message that will be sent to the request.
  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "Lav en aftensmadsret. Du må bruge nogle disse ingredienser ${kSampleIngredients.map((e) => e.toMap())} ikke andre",
      ),
    ],
    role: OpenAIChatMessageRole.user,
  );

  // requirement
  final requirementsMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "krav til retten: ${requirements.join(',')}",
      ),
    ],
    role: OpenAIChatMessageRole.user,
  );

// all messages to be sent.
  final requestMessages = [
    systemMessage,
    userMessage,
    requirementsMessage,
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
