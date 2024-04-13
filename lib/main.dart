import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:mad_app_eksamensprojekt/models/recipe.dart';
import 'package:mad_app_eksamensprojekt/shared/all_ingredients.dart';
import 'package:mad_app_eksamensprojekt/shared/recipe_examples.dart';

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
      home: MyHomePage(title: 'Teknologi Årsprojekt'),
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
  final List<Ingredient> ingredients = Recipe.fromMap(recipeExamples.first).ingredientsToBuy;

  OpenAIChatCompletionModel? content;

  @override
  Widget build(BuildContext context) {
    print(Recipe.fromMap(recipeExamples.first).ingredientsForRecipe);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            content == null
                ? SizedBox.shrink()
                : Text(jsonDecode(content!.choices.first.message.content!.first.text!).toString()),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final Ingredient currentIngredient = kSampleIngredients[index];
                  return ListTile(
                    title: Text(currentIngredient.name),
                    trailing: Text("${currentIngredient.price} .-"),
                    subtitle: Text(
                        "${currentIngredient.quantity} ${currentIngredient.unit}"),
                  );
                }),
            OutlinedButton(
                onPressed: () async {
                  final response = await _apiExample();
                  setState(() {
                    content = response;
                  });
                },
                child: Text("Server"))
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
        "return any message you are given as JSON.",
      ),
    ],
    role: OpenAIChatMessageRole.assistant,
  );

  // the user message that will be sent to the request.
  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "make a dog class",
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
    maxTokens: 500,
  );

  print(chatCompletion.choices.first.message.content); // ...
  print(chatCompletion.systemFingerprint); // ...
  print(chatCompletion.usage.promptTokens); // ...
  print(chatCompletion.id);
  return chatCompletion;
}
