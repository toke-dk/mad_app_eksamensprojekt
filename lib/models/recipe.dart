import 'package:mad_app_eksamensprojekt/models/ingredient.dart';

class Recipe {
  String name;
  String description;
  List<Map<int, Ingredient>> ingredientsWithQuantity;
  List<String> instructions;

  Recipe(
      {required this.name,
      required this.description,
      required this.ingredientsWithQuantity,
      required this.instructions});
}
