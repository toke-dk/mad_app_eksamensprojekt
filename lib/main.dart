import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:mad_app_eksamensprojekt/models/recipe.dart';
import 'package:mad_app_eksamensprojekt/models/recipe_suggestion.dart';
import 'package:mad_app_eksamensprojekt/pages/recipe_page.dart';
import 'package:mad_app_eksamensprojekt/providers/recipes_provider.dart';
import 'package:mad_app_eksamensprojekt/shared/all_ingredients.dart';
import 'package:mad_app_eksamensprojekt/shared/openai_extensions.dart';
import 'package:mad_app_eksamensprojekt/shared/recipe_examples.dart';
import 'package:mad_app_eksamensprojekt/shared/widgets/my_value_changer.dart';
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
  List<Ingredient> get ingredients => recipes.first.ingredientsForRecipe;

  List<Recipe> get recipes => Provider.of<RecipesProvider>(context).getRecipes;

  OpenAIChatCompletionModel? content;
  bool onlyVegitarian = false;
  bool onlyVegan = false;
  bool noLactose = false;
  bool noGluten = false;

  List<String> get generateRestrictions {
    List<String> restrictions = [];
    if (onlyVegitarian) restrictions.add("vegetarisk");
    if (onlyVegan) restrictions.add("vegansk");
    if (noLactose) restrictions.add("laktosefrit");
    if (noGluten) restrictions.add("glutenfrit");
    return restrictions;
  }

  OpenAIChatCompletionModel? creativeDishesFromAI;

  List<RecipeSuggestion> recipeSuggestions = [];

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
                  final OpenAIChatCompletionModel result =
                      await createDishSuggestions(2, generateRestrictions);

                  final List<dynamic> recipesMap =
                      result.myJsonDecode["recipes"];

                  final List<RecipeSuggestion> suggestions = recipesMap
                      .map((e) => RecipeSuggestion.fromMap(e))
                      .toList();

                  setState(() {
                    recipeSuggestions.addAll(suggestions);
                  });
                },
                child: Text("Foreslå retter")),
            MyValueChanger(handleValueChange: (newVal){}, value: 1, minValue: 1,),
            OutlinedButton(
                onPressed: () async {
                  final response = await _apiExample(generateRestrictions);

                  Provider.of<RecipesProvider>(context, listen: false)
                          .addAllRecipes =
                      (response.myJsonDecode["recipes"] as List<dynamic>)
                          .map((e) => Recipe.fromMap(e))
                          .toList();

                  debugPrint(response.myJsonDecode.toString());
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
                        "${indexRecipe.durationInMins} minutter, ${indexRecipe.ingredientsForRecipe.length} ingredienser"),
                  );
                }),
            Divider(),
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: recipeSuggestions.length,
                itemBuilder: (context, index) {
                  final RecipeSuggestion indexSuggestion =
                      recipeSuggestions[index];
                  print(indexSuggestion);
                  return ListTile(
                    title: Text(indexSuggestion.title),
                    subtitle: Text(indexSuggestion.shortDescription),
                  );
                }),
            Divider(),
            OutlinedButton(
                onPressed: () {
                  Provider.of<RecipesProvider>(context, listen: false)
                      .addRecipe = Recipe.fromMap(recipeExamples.first);
                },
                child: Text("Add exampleIngredient")),
            OutlinedButton(
                onPressed: () {
                  print((content!.myJsonDecode["recipes"] as List<dynamic>)
                      .map((e) => Recipe.fromMap(e))
                      .toList());

                  Provider.of<RecipesProvider>(context, listen: false)
                          .addAllRecipes =
                      (content!.myJsonDecode["recipes"] as List<dynamic>)
                          .map((e) => Recipe.fromMap(e))
                          .toList();
                  print(Provider.of<RecipesProvider>(context, listen: false)
                      .getRecipes);
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
          "recipes": [{
            "name": TEXT,
            "description": TEXT,
            "durationInMins": INTEGER,
            "ingredientsForRecipe": List<{"name": TEXT, "quantity": DOUBLE, "unit": STRING, "price": DOUBLE}>,
            "instructions": List<TEXT>,
          }]
        ''',
      ),
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "Hvor 'ingredientsForRecipe' beskriver hvor meget af en ingrediens der bliver brugt i opskriften. unit må kun være: g/mL/stk/tsk/spsk/fed",
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
        "Lav 2 aftensmadsretter til en mand på 18",
      ),
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "Krav til retten er dog at den skal være: ${requirements.join(',')}",
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
    model: "gpt-3.5-turbo-0125",
    responseFormat: {"type": "json_object"},
    seed: 6,
    messages: requestMessages,
    temperature: 1,
    maxTokens: 700,
  );

  return chatCompletion;
}

Future<OpenAIChatCompletionModel> createDishSuggestions(
    int amountOfSuggestions, List<String> requirements) async {
  OpenAI.apiKey = Env.apiKey;

  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        '''de givne beskeder skal følge JSON-formatet:
          {"recipes": [{"title": TEXT,"shortDescription": TEXT}]}
        ''',
      ),
    ],
    role: OpenAIChatMessageRole.assistant,
  );

  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "Giv $amountOfSuggestions forslag til aftensmadsretter til en mand på 18 år"),
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "Krav til retten er dog at den skal være: ${requirements.join(',')}",
      ),
    ],
    role: OpenAIChatMessageRole.user,
  );

  final requestMessages = [
    systemMessage,
    userMessage,
  ];

  OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-0125",
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      temperature: 1,
      maxTokens: 700);

  return chatCompletion;
}
