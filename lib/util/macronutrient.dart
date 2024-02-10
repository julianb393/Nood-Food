import 'package:nood_food/models/food.dart';

double computeTotalCalories(double protein, double carbs, double fat) {
  return protein * 4 + carbs * 4 + fat * 9;
}

double computeTotalCaloriesFromFood(Food food) {
  return food.protein * 4 + food.carbs * 4 + food.fat * 9;
}
