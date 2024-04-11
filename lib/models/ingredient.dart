class Ingredient {
  String name;
  double priceInDKK;
  PriceUnit priceUnit;
  double? weightInKg;

  Ingredient(
      {required this.name, required this.priceInDKK, required this.priceUnit, this.weightInKg}) {
    if (priceUnit == PriceUnit.prKg && weightInKg == null) {
      throw ArgumentError('Vægt skal angives for madvarer pr. kg.');
    }
  }

  double? get getKgPrice {
    if (weightInKg == null) return null;
    return priceInDKK/weightInKg!;
  }

}

enum PriceUnit { prKg, prPiece }
