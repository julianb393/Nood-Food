import 'package:flutter/material.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/views/meal_details.dart';

class MealButton extends StatelessWidget {
  final String name;
  final List<Map<String, dynamic>> meals;
  const MealButton({super.key, required this.name, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MealDetails(
                        mealName: name,
                      )));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name),
            Text('Calories: ${meals.fold(
              0.0,
              (currVal, element) =>
                  currVal +
                  computeTotalCalories(
                    (element['protein'] as num).toDouble(),
                    (element['carbs'] as num).toDouble(),
                    (element['fat'] as num).toDouble(),
                  ),
            )}')
          ],
        ),
      ),
    );
  }
}
