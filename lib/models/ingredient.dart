class Ingredient {
  String name;
  double priceInDKK;
  QuantityType quantityType;
  double? weightInGram;

  Ingredient(
      {required this.name,
      required this.priceInDKK,
      required this.quantityType,
      this.weightInGram}) {
    if (quantityType == QuantityType.prGram && weightInGram == null) {
      throw ArgumentError('Vægt skal angives for madvarer pr. kg.');
    }
  }

  String get getQuantityString {
    switch (quantityType) {
      case QuantityType.prPiece:
        return 'pr. styk';
      case QuantityType.prGram:
        return '$weightInGram kg';
      case QuantityType.bunch:
        return 'pr. bdt';
    }
  }

  double? get getKgPrice {
    if (weightInGram == null) return null;
    return priceInDKK / weightInGram!;
  }
}

enum QuantityType { prGram, prPiece, bunch }
