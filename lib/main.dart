import 'package:flutter/material.dart';
import 'package:mad_app_eksamensprojekt/all_ingredients.dart';

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
              })
        ],
      ),
    );
  }
}
