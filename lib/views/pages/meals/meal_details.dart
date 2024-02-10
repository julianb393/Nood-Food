import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/views/pages/meals/food_editor.dart';
import 'package:pie_chart/pie_chart.dart';

class MealDetails extends StatelessWidget {
  final MealType mealType;
  final DateTime day;
  final List<Food> foods;

  const MealDetails(
      {super.key,
      required this.mealType,
      required this.foods,
      required this.day});

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
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: DataTable2(
                columnSpacing: 40,
                showBottomBorder: true,
                isVerticalScrollBarVisible: true,
                columns: const [
                  DataColumn2(label: Text('Food')),
                  DataColumn2(label: Text('Quantity')),
                  DataColumn2(label: Text('Calories'))
                ],
                rows: foods
                    .map((food) => DataRow2(
                          cells: [
                            DataCell(Text(food.name, softWrap: true)),
                            DataCell(Text('${food.quantity.toString()} g')),
                            DataCell(Text(computeTotalCaloriesFromFood(food)
                                .toStringAsFixed(2))),
                          ],
                        ))
                    .toList(),
              ),
            ),
            Expanded(
              flex: 1,
              child: PieChart(
                chartRadius: 170,
                dataMap: {
                  'protein': totalProtein,
                  'carbs': totalCarbs,
                  'fat': totalFat
                },
                formatChartValues: (double val) =>
                    '${val.toStringAsFixed(2)} g',
                centerText: '${computeTotalCalories(
                  totalProtein,
                  totalCarbs,
                  totalFat,
                ).toStringAsFixed(2)} kcal',
              ),
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
              return FoodEditor(mealType: mealType, day: day);
            },
          );
        },
      ),
    );
  }
}
