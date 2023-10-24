import 'package:flutter/material.dart';
import 'package:nood_food/views/meal_viewer.dart';
import 'package:pie_chart/pie_chart.dart';

class EditMeals extends StatelessWidget {
  const EditMeals({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, double>> mealsToNutritions = {
      'Breakfast': {
        'Carbohydrates': 1,
        "Fat": 1,
        'Salt': 1,
        "Sugars": 1,
        "Saturated Fat": 1,
        "Protein": 1,
        "Sodium": 2,
      },
      'Lunch': {
        'Carbohydrates': 1,
        "Fat": 1,
        'Salt': 1,
        "Sugars": 1,
        "Saturated Fat": 1,
        "Protein": 1,
        "Sodium": 2,
      },
      'Dinner': {
        'Carbohydrates': 1,
        "Fat": 1,
        'Salt': 1,
        "Sugars": 1,
        "Saturated Fat": 1,
        "Protein": 1,
        "Sodium": 2,
      },
      'Snacks': {
        'Carbohydrates': 1,
        "Fat": 1,
        'Salt': 1,
        "Sugars": 1,
        "Saturated Fat": 1,
        "Protein": 1,
        "Sodium": 2,
      }
    };

    List<String> meals = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meals'),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (String meal in meals)
            SizedBox(
              height: MediaQuery.of(context).size.height / 4 -
                  (MediaQuery.of(context).padding.top / 4 +
                      kBottomNavigationBarHeight / 4),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MealViewer(meal: meal)));
                },
                child: Card(
                  child: Column(
                    children: [
                      Text(meal),
                      Expanded(
                        child: PieChart(dataMap: mealsToNutritions[meal]!),
                      )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
