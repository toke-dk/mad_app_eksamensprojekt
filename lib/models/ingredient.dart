class Ingredient {
  String name;
  String category;
  double quantity;
  String unit;
  double price;

  Ingredient({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  // To map: create a new Map with field names as keys and their values
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'price': price,
    };
  }

  // From map: takes a Map and populates the Ingredient object
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: double.parse(map['quantity'].toString()),
      unit: map['unit'] as String,
      price: double.parse(map['quantity'].toString()),
    );
  }
}

const _jsonFormatComment = '''
This is how the format for the ingredient should be
{"name": str, "category": str, "quantity": double, "unit": str, "price": double}
''';