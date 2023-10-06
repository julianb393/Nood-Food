import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class EditMeals extends StatelessWidget {
  const EditMeals({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, double>> mealsToNutritions = {
      'Breakfast': {
        "Fat": 1,
        "Sugars": 1,
        "Saturated Fat": 1,
        "Protein": 1,
        "Sodium": 2,
      },
      'Lunch': {
        "Fat": 1,
        "Sugars": 1,
        "Saturated Fat": 1,
        "Protein": 1,
        "Sodium": 2,
      },
      'Dinner': {
        "Fat": 1,
        "Sugars": 0,
        "Saturated Fat": 1,
        "Protein": 1,
        "Sodium": 2,
      },
      'Snacks': {
        "Fat": 0,
        "Sugars": 0,
        "Saturated Fat": 0,
        "Protein": 0,
        "Sodium": 0,
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
                  print('tapped');
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
    //   Text('Breakfast'),
    //   Expanded(
    //     child: breakfastDM.isEmpty
    //         ? const SizedBox()
    //         : PieChart(dataMap: breakfastDM),
    //   ),
    //   Text('Lunch'),
    //   Expanded(
    //       child: lunchDM.isEmpty
    //           ? const SizedBox()
    //           : PieChart(dataMap: lunchDM)),
    //   Text('Dinner'),
    //   Expanded(
    //       child: dinnerDM.isEmpty
    //           ? const SizedBox()
    //           : PieChart(dataMap: dinnerDM)),
    //   Text('Snacks'),
    //   Expanded(
    //       child: snacksDM.isEmpty
    //           ? const SizedBox()
    //           : PieChart(dataMap: snacksDM))
    // ],
  }
}
