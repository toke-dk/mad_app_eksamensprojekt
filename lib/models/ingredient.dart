class Ingredient {
  String name;
  double priceInDKK;
  QuantityType quantityType;
  double? weightInKg;

  Ingredient(
      {required this.name,
      required this.priceInDKK,
      required this.quantityType,
      this.weightInKg}) {
    if (quantityType == QuantityType.prKg && weightInKg == null) {
      throw ArgumentError('Vægt skal angives for madvarer pr. kg.');
    }
  }

  String get getQuantityString {
    switch (quantityType) {
      case QuantityType.prPiece:
        return 'pr. styk';
      case QuantityType.prKg:
        return '$weightInKg kg';
      case QuantityType.bunch:
        return 'pr. bdt';
    }
  }

  double? get getKgPrice {
    if (weightInKg == null) return null;
    return priceInDKK / weightInKg!;
  }
}

enum QuantityType { prKg, prPiece, bunch }
