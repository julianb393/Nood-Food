import 'package:flutter/material.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/util/string_extension.dart';
import 'package:nood_food/views/pages/meals/food_editor.dart';
import 'package:pie_chart/pie_chart.dart';

class MealDetails extends StatelessWidget {
  final MealType mealType;

  const MealDetails({super.key, required this.mealType});

  static final List<Map<String, dynamic>> foodSamples = [
    {
      'name': 'Orville\'s Popcorn',
      'quantity': '1 cup',
      'protein': 120,
      'carbs': 200,
      'fat': 150,
      'calories': '120kcal',
    },
    {
      'name': 'Large eggs',
      'quantity': '2',
      'protein': 200,
      'carbs': 30,
      'fat': 150,
      'calories': '120kcal',
    },
    {
      'name': 'Bacon',
      'quantity': '2',
      'protein': 200,
      'carbs': 30,
      'fat': 150,
      'calories': '120kcal',
    },
    {
      'name': 'French Toast',
      'quantity': '2 slices',
      'protein': 200,
      'carbs': 30,
      'fat': 150,
      'calories': '120kcal',
    },
    {
      'name': 'Orange Juice',
      'quantity': '1 cup',
      'protein': 200,
      'carbs': 30,
      'fat': 150,
      'calories': '120kcal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    foodSamples.forEach((food) {
      totalProtein += food['protein'] as num;
      totalCarbs += food['carbs'] as num;
      totalFat += food['fat'] as num;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(mealType.name.capitalize()),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 25, 15, 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DataTable(
              columns: const [
                DataColumn(label: Text('Food')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Calories'))
              ],
              rows: foodSamples
                  .map((food) => DataRow(cells: [
                        DataCell(Text(food['name']!)),
                        DataCell(Text(food['quantity']!)),
                        DataCell(Text(food['calories']!)),
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
              formatChartValues: (double val) => '$val g',
              centerText:
                  '${computeTotalCalories(totalProtein, totalCarbs, totalFat)} kcal',
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
