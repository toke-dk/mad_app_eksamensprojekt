import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mad_app_eksamensprojekt/models/recipe.dart';
import 'package:mad_app_eksamensprojekt/models/recipe_suggestion.dart';
import 'package:mad_app_eksamensprojekt/pages/shopping_list.dart';
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
    return ChangeNotifierProvider(
      create: (context) => RecipesProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Teknologi Årsprojekt'),
      ),
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

  int amountOfDishesToCreate = 1;

  bool isLoadingDishes = false;

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
                title: const Text("Vegetar"),
                value: onlyVegitarian,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    onlyVegitarian = val;
                  });
                }),
            CheckboxListTile(
                title: const Text("Vegansk"),
                value: onlyVegan,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    onlyVegan = val;
                  });
                }),
            CheckboxListTile(
                title: const Text("Laktosefri"),
                value: noLactose,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    noLactose = val;
                  });
                }),
            CheckboxListTile(
                title: const Text("Glutenfri"),
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
                      await createDishSuggestions(
                          amountOfDishesToCreate, generateRestrictions);

                  final List<dynamic> recipesMap =
                      result.myJsonDecode["recipes"];

                  final List<RecipeSuggestion> suggestions = recipesMap
                      .map((e) => RecipeSuggestion.fromMap(e))
                      .toList();

                  setState(() {
                    recipeSuggestions.addAll(suggestions);
                  });
                },
                child: const Text("Foreslå retter")),
            Text(
              "Antal retter",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            MyValueChanger(
              handleValueChange: (newVal) {
                setState(() {
                  amountOfDishesToCreate = newVal;
                });
              },
              value: 1,
              minValue: 1,
              maxValue: 7,
            ),
            OutlinedButton(
                onPressed: () async {
                  setState(() {
                    isLoadingDishes = true;
                  });
                  final response = await _apiExample(
                      requirements: generateRestrictions,
                      amountOfDishes: amountOfDishesToCreate);

                  setState(() {
                    isLoadingDishes = false;
                    content = response;
                  });

                  Provider.of<RecipesProvider>(context, listen: false)
                          .addAllRecipes =
                      (response.myJsonDecode["recipes"] as List<dynamic>)
                          .map((e) => Recipe.fromMap(e))
                          .toList();

                  debugPrint(response.myJsonDecode.toString());
                },
                child: const Text("Skab ret")),
            !isLoadingDishes
                ? const SizedBox.shrink()
                : const FittedBox(child: CircularProgressIndicator()),
            const Divider(),
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final Recipe indexRecipe = recipes[index];
                  return Dismissible(
                    key: Key("item-$index"),
                    background: Container(
                      color: Colors.red,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.delete_forever),
                          Icon(Icons.delete_forever),
                        ],
                      ),
                    ),
                    onDismissed: (direction) =>
                        Provider.of<RecipesProvider>(context, listen: false)
                            .removeRecipe(indexRecipe),
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () async {
                          setState(() {
                            isLoadingDishes = true;
                          });

                          final response = await _apiExample(
                              requirements: generateRestrictions,
                              amountOfDishes: 1);

                          setState(() {
                            isLoadingDishes = false;
                          });

                          final Recipe recipeToReplace = (response
                                  .myJsonDecode["recipes"] as List<dynamic>)
                              .map((e) => Recipe.fromMap(e))
                              .first;

                          Provider.of<RecipesProvider>(context, listen: false)
                              .replaceRecipe(indexRecipe, recipeToReplace);
                        },
                      ),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RecipePage(recipe: indexRecipe))),
                      title: Text(indexRecipe.name),
                      trailing: Text(
                          "${indexRecipe.getTotalPrice.roundToDouble()} .-"),
                      subtitle: Text(
                          "${indexRecipe.durationInMins} minutter, ${indexRecipe.ingredientsForRecipe.length} ingredienser"),
                    ),
                  );
                }),
            OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ShoppingListPage())),
                child: Text("Se ingredienserne")),
            const Divider(),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
            const Divider(),
            OutlinedButton(
                onPressed: () {
                  Provider.of<RecipesProvider>(context, listen: false)
                      .addRecipe = Recipe.fromMap(recipeExamples.first);
                },
                child: const Text("Add exampleIngredient")),
            OutlinedButton(
                onPressed: () {
                  String myString = content!
                      .choices.first.message.content!.first.text
                      .toString();
                  int startIndex = 1800;
                  int endIndex = myString.length;

                  String substring = myString.substring(startIndex, endIndex);
                  print(substring);

                  //print(content!.myJsonDecode);
                },
                child: const Text("debug print"))
          ],
        ),
      ),
    );
  }
}

Future<OpenAIChatCompletionModel> _apiExample(
    {required List<String> requirements, required int amountOfDishes}) async {
  OpenAI.apiKey = Env.apiKey;
  // the system message that will be sent to the request.
  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        '''de givne beskeder skal følge opskrift JSON-formatet på dansk:
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
        "unit må kun være: g/mL/stk/tsk/spsk/fed",
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
        "Giv $amountOfDishes unik forslag aftensmadsret til en mand på 18",
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
    messages: requestMessages,
    temperature: 1,
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
