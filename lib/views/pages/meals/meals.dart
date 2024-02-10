import 'package:flutter/material.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/views/pages/meals/meal_details.dart';
import 'package:nood_food/views/pages/meals/meal_tab.dart';
import 'package:provider/provider.dart';

class Meals extends StatefulWidget {
  const Meals({super.key});

  @override
  State<Meals> createState() => _MealsState();
}

class _MealsState extends State<Meals> {
  Map<MealType, List<Food>> _initMealToFoodsMap(List<Food> foods) {
    Map<MealType, List<Food>> mealToFoods =
        MealType.values.asMap().map((key, meal) => MapEntry(meal, []));

    for (Food food in foods) {
      mealToFoods[food.meal]!.add(food);
    }
    return mealToFoods;
  }

  @override
  Widget build(BuildContext context) {
    final List<Food> foods = Provider.of<List<Food>>(context);
    final Map<MealType, List<Food>> mealToFoods = _initMealToFoodsMap(foods);
    return DefaultTabController(
      length: MealType.values.length,
      child: Column(
        children: [
          TabBar(
            tabs: MealType.values.map((meal) => MealTab(meal: meal)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: MealType.values
                  .map((meal) => MealDetails(
                        mealType: meal,
                        foods: mealToFoods[meal]!,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
