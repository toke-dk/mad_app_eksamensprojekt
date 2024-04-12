import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:mad_app_eksamensprojekt/all_ingredients.dart';

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

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  final List<Ingredient> ingredients = kSampleIngredients;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final Ingredient currentIngredient = kSampleIngredients[index];
                return ListTile(
                  title: Text(currentIngredient.name),
                  trailing: Text("${currentIngredient.priceInDKK} .-"),
                  subtitle: Text(
                      "${currentIngredient.getQuantityString} ${currentIngredient.getKgPrice ?? ''}"),
                );
              }),
          OutlinedButton(onPressed: (){_apiExample();}, child: Text("Server"))
        ],
      ),
    );
  }
}

Future<void> _apiExample() async {
  print("here");
  OpenAI.apiKey = Env.apiKey;
  OpenAICompletionModel completion = await OpenAI.instance.completion.create(
    model: "gpt-3.5-turbo-instruct",
    prompt: "Dart is a program",
    maxTokens: 20,
    temperature: 0.5,
    n: 1,
    stop: ["\n"],
    echo: true,
    seed: 42,
    bestOf: 2,
  );

  print(completion.choices.first.text); // ...
  print(completion.systemFingerprint); // ...
  print(completion.id); // ...
}
