enum Unit {
  grams(symbol: "g", gramsConversion: 1),
  cups(symbol: "cups", gramsConversion: 340),
  tablespoon(symbol: "tbsp", gramsConversion: 14.175),
  teaspoon(symbol: "tsp", gramsConversion: 5.69),
  ounce(symbol: "oz", gramsConversion: 28.3495);

  const Unit({
    required this.symbol,
    required this.gramsConversion,
  });

  final String symbol;
  final double gramsConversion;
}

Unit parseUnitFromSymbol(String symbol) {
  return Unit.values.firstWhere((element) => element.symbol == symbol);
}

double convertToGrams(Unit unit, double value) {
  return unit.gramsConversion * value;
}

String convertStrToGrams(String unitStr, String value) {
  if (unitStr == 'g') return value;
  Unit unit = Unit.values.firstWhere((unit) => unit.symbol == unitStr);
  return convertToGrams(unit, double.parse(value)).toStringAsFixed(2);
}
