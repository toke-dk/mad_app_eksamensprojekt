import 'dart:convert';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Ingredient> ingredients = kSampleIngredients;

  OpenAIChatCompletionModel? content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          content == null
              ? SizedBox.shrink()
              : Text(jsonDecode(content!.choices.first.message.content!.first.text!).toString()),
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
