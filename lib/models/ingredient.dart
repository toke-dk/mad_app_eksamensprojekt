class Ingredient {
  String name;
  double quantity;
  String unit;
  double price;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  // To map: create a new Map with field names as keys and their values
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
    };
  }

  // From map: takes a Map and populates the Ingredient object
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String,
      quantity: double.parse(map['quantity'].toString()),
      unit: map['unit'] as String,
      price: double.parse(map['price'].toString()),
    );
  }
}

extension IngredientsExtension on List<Ingredient> {
  double get getTotalPrice =>
      map((e) => e.price).reduce((value, element) => value + element);

  List<String> get getngredientsNameLowerCase => map((e) => e.name.toLowerCase()).toList();
}

const _jsonFormatComment = '''
This is how the format for the ingredient should be
{"name": str, "category": str, "quantity": double, "unit": str, "price": double}
''';
