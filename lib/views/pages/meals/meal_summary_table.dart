import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/meal_type.dart';
import 'package:nood_food/views/pages/meals/food_editor.dart';

class MealSummaryTable extends StatelessWidget {
  final List<Food> foods;
  final MealType meal;
  final DateTime day;
  const MealSummaryTable({
    super.key,
    required this.foods,
    required this.meal,
    required this.day,
  });

  /// Navigates to the Food Editor page. If [foodtoView] was provided, then we
  /// initialize the state has being in vieweing which will allow uses to edit
  /// the record if they wish to. Otherwise, the Food Editor will be open with
  /// no fields filled, assuming the user wants to create a nthis.ew Food record.
  void _navigateToFoodEditor(BuildContext context, Food? foodToView) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodEditor(
          mealType: meal,
          day: day,
          food: foodToView,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DataTable2(
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
                onTap: () => _navigateToFoodEditor(context, food),
                cells: [
                  DataCell(Text(food.name, softWrap: true)),
                  DataCell(Text(
                      '${food.consumedAmount.toString()} ${food.consumedUom}')),
                  DataCell(Text(computeTotalCaloriesFromFood(food).toString())),
                ],
              ))
          .toList(),
    );
  }
}
