import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/util/style.dart';
import 'package:nood_food/views/pages/meals/meal_details.dart';
import 'package:nood_food/views/pages/meals/meal_tab.dart';
import 'package:provider/provider.dart';

class Meals extends StatefulWidget {
  final DateTime day;
  const Meals({super.key, required this.day});

  @override
  State<Meals> createState() => _MealsState();
}

class _MealsState extends State<Meals> {
  final DateFormat _df = DateFormat(DateFormat.YEAR_MONTH_DAY);
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
            labelPadding: EdgeInsets.zero,
            tabs: MealType.values.map((meal) => MealTab(meal: meal)).toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: StyledText.titleLarge(_df.format(widget.day)),
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: MealType.values
                  .map((meal) => MealDetails(
                        mealType: meal,
                        foods: mealToFoods[meal]!,
                        day: widget.day,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
