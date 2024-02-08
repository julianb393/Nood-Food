import 'package:nood_food/util/meal_type.dart';

/// Class that models a Food whose [quantity] is measured in grams and the other
/// fields dictates macronutrients per quantity gram, i.e. consumed grams.
class Food {
  String name;
  double quantity;
  double protein;
  double carbs;
  double fat;
  MealType meal;
  Food(this.name, this.quantity, this.protein, this.carbs, this.fat, this.meal);
}
