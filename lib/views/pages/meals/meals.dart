import 'package:flutter/material.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/util/string_extension.dart';
import 'package:nood_food/views/pages/meals/meal_details.dart';

class Meals extends StatelessWidget {
  const Meals({super.key});

  void _navigateToDetails(MealType meal, BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MealDetails(mealType: meal)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: MealType.values // change import
          .map(
            (meal) => Card(
              child: InkWell(
                onTap: () => _navigateToDetails(meal, context),
                child: ListTile(
                  title: Text(meal.name.capitalize()),
                  leading: Icon(meal.getIcon()),
                  trailing: const Icon(Icons.edit_note_sharp, size: 35),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
