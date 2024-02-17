import 'package:nood_food/models/nutritional_facts.dart';
import 'package:nood_food/util/meal_type.dart';

/// Class that models a Food whose [quantity] is measured in [quantityUom].
class Food {
  // Only set when retrieved from db.
  String? uid;
  String name;
  double consumedAmount;
  String consumedUom;
  NutritionalFacts nutrition;
  MealType meal;
  Food({
    this.uid,
    required this.name,
    required this.consumedAmount,
    required this.consumedUom,
    required this.nutrition,
    required this.meal,
  });

  double computeConsumedProtein() {
    if (nutrition.amount == 0) {
      return 0.0;
    }
    return double.parse((nutrition.protein / nutrition.amount * consumedAmount)
        .toStringAsFixed(2));
  }

  double computeConsumedCarbs() {
    if (nutrition.amount == 0) {
      return 0.0;
    }
    return double.parse((nutrition.carbs / nutrition.amount * consumedAmount)
        .toStringAsFixed(2));
  }

  double computeConsumedFat() {
    if (nutrition.amount == 0) {
      return 0.0;
    }
    return double.parse(
        (nutrition.fat / nutrition.amount * consumedAmount).toStringAsFixed(2));
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'consumed_quantity': consumedAmount,
      'consumed_uom': consumedUom,
      'nutritional_facts': nutrition.toJson(),
      'meal': meal.name,
    };
  }

  Food clone() {
    return Food(
        uid: uid,
        name: name,
        consumedAmount: consumedAmount,
        consumedUom: consumedUom,
        nutrition: nutrition.clone(),
        meal: meal);
  }

  @override
  bool operator ==(Object other) {
    return other is Food &&
        name == other.name &&
        consumedAmount == other.consumedAmount &&
        consumedUom == other.consumedUom &&
        nutrition == other.nutrition &&
        meal == other.meal;
  }

  @override
  int get hashCode =>
      Object.hash(uid, name, consumedAmount, consumedUom, nutrition, meal);
}
