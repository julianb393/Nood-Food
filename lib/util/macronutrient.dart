import 'package:nood_food/models/food.dart';

double computeTotalCalories(double protein, double carbs, double fat) {
  return roundTwoDecimalPlaces(protein * 4 + carbs * 4 + fat * 9);
}

double computeTotalCaloriesFromFood(Food food) {
  return roundTwoDecimalPlaces(food.computeConsumedProtein() * 4 +
      food.computeConsumedCarbs() * 4 +
      food.computeConsumedFat() * 9);
}

double roundTwoDecimalPlaces(double value) {
  return double.parse(value.toStringAsFixed(2));
}
