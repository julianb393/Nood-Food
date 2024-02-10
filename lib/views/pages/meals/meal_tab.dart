import 'package:flutter/material.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/util/string_extension.dart';

class MealTab extends StatelessWidget {
  final MealType meal;
  const MealTab({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Icon(meal.getIcon()), Text(meal.name.capitalize())],
    );
  }
}
