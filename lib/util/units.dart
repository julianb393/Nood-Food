import 'package:units_converter/units_converter.dart';

final availableUnits = [
  Unit(name: 'grams', symbol: 'g'),
  Unit(name: 'cups', symbol: 'cups'),
  Unit(name: 'milliliters', symbol: 'ml'),
  Unit(name: 'tablespoon', symbol: 'tbsp'),
  Unit(name: 'teaspoon', symbol: 'tsp')
];

class Unit {
  String name;
  String symbol;

  Unit({required this.name, required this.symbol});

  double convertTo(double value, Unit convertToUnit) {
    double? converted = value.convertFromTo(name, convertToUnit.name);
    if (converted == null) {
      print('could not convert $value');
      return value;
    }
    return converted;
  }
}
