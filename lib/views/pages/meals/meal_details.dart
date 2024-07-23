import 'package:flutter/material.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/util/style.dart';
import 'package:nood_food/views/pages/meals/food_editor.dart';
import 'package:nood_food/views/pages/meals/meal_summary_table.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class MealDetails extends StatelessWidget {
  final MealType mealType;
  final DateTime day;
  final List<Food> foods;

  const MealDetails(
      {super.key,
      required this.mealType,
      required this.foods,
      required this.day});

  /// Navigates to the Food Editor page. If [foodtoView] was provided, then we
  /// initialize the state has being in vieweing which will allow uses to edit
  /// the record if they wish to. Otherwise, the Food Editor will be open with
  /// no fields filled, assuming the user wants to create a nthis.ew Food record.
  void _navigateToFoodEditor(BuildContext context, Food? foodToView) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodEditor(
          mealType: mealType,
          day: day,
          food: foodToView,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    for (var food in foods) {
      totalProtein += food.computeConsumedProtein();
      totalCarbs += food.computeConsumedCarbs();
      totalFat += food.computeConsumedFat();
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: MealSummaryTable(foods: foods, meal: mealType, day: day),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
                    child: StyledText.displayLarge(
                        'Calories Consumed: ${computeTotalCalories(totalProtein, totalCarbs, totalFat)} kcal'),
                  ),
                  PrimerProgressBar(
                    segments: [
                      Segment(
                        value: totalProtein.toInt(),
                        color: Colors.blue,
                        label: const Text('Protein (g)'),
                      ),
                      Segment(
                        value: totalFat.toInt(),
                        color: Colors.red,
                        label: const Text('Fat (g)'),
                      ),
                      Segment(
                        value: totalCarbs.toInt(),
                        color: Colors.green,
                        label: const Text('Carbs (g)'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _navigateToFoodEditor(context, null)),
    );
  }
}
