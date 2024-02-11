import 'package:nood_food/models/food.dart';

double computeTotalCalories(double protein, double carbs, double fat) {
  return double.parse((protein * 4 + carbs * 4 + fat * 9).toStringAsFixed(2));
}

double computeTotalCaloriesFromFood(Food food) {
  return food.computeConsumedProtein() * 4 +
      food.computeConsumedCarbs() * 4 +
      food.computeConsumedFat() * 9;
}
