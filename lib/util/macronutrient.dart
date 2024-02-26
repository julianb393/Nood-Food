import 'package:nood_food/models/food.dart';
import 'package:nood_food/util/active_level.dart';

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

/// For women, BMR = 655.1 + (9.563 x weight in kg) + (1.850 x height in cm) - (4.676 x age in years)
/// For men, BMR = 66.47 + (13.75 x weight in kg) + (5.003 x height in cm) - (6.755 x age in years)
double? computeRecommendedCalories(
    String? sex, double? weight, double? height, int? age, ActiveLevel? level) {
  if (sex == null ||
      weight == null ||
      height == null ||
      age == null ||
      level == null) {
    return null;
  }

  double bmr;
  if (sex == 'Male') {
    bmr = 655.1 +
        (9.563 * (weight * 0.453592)) +
        (1.850 * height) -
        (4.676 * age);
  } else if (sex == 'Female') {
    bmr = 66.47 +
        (13.75 * (weight * 0.453592)) +
        (5.003 * height) -
        (6.755 * age);
  } else {
    return null;
  }
  return bmr * level.amrMultiplier;
}
