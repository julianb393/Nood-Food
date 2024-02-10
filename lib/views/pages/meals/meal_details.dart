import 'package:flutter/material.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/views/pages/meals/food_editor.dart';
import 'package:pie_chart/pie_chart.dart';

class MealDetails extends StatelessWidget {
  final MealType mealType;
  final List<Food> foods;

  const MealDetails({super.key, required this.mealType, required this.foods});

  @override
  Widget build(BuildContext context) {
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    foods.forEach((food) {
      totalProtein += food.protein;
      totalCarbs += food.carbs;
      totalFat += food.fat;
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 25, 15, 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DataTable(
              columns: const [
                DataColumn(label: Text('Food')),
                DataColumn(label: Text('Quantity(g)')),
                DataColumn(label: Text('Calories(kcal)'))
              ],
              rows: foods
                  .map((food) => DataRow(cells: [
                        DataCell(Text(food.name)),
                        DataCell(Text(food.quantity.toString())),
                        DataCell(Text(computeTotalCaloriesFromFood(food)
                            .toStringAsFixed(2))),
                      ]))
                  .toList(),
            ),
            PieChart(
              chartRadius: 170,
              dataMap: {
                'protein': totalProtein,
                'carbs': totalCarbs,
                'fat': totalFat
              },
              formatChartValues: (double val) => '${val.toStringAsFixed(2)} g',
              centerText: '${computeTotalCalories(
                totalProtein,
                totalCarbs,
                totalFat,
              ).toStringAsFixed(2)} kcal',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return FoodEditor(mealType: mealType);
            },
          );
        },
      ),
    );
  }
}
