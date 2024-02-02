import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/util/custom_widgets/meal_button.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/samples.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:weekly_date_picker/weekly_date_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dailyCaloriesAllowed = 3200.0;
  Map<String, double> totalConsumedSample = {
    'protein': 120,
    'carbs': 300,
    'fat': 150,
    'calories': computeTotalCalories(120, 300, 150),
  };

  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat.yMMMMd().format(_selectedDay)),
          WeeklyDatePicker(
            selectedDay: _selectedDay,
            changeDay: (value) => setState(() {
              _selectedDay = value;
            }),
            enableWeeknumberText: false,
            backgroundColor: Colors.transparent,
            weekdayTextColor: const Color(0xFF8A8A8A),
            digitsColor: Colors.white,
          ),
          const Text('Welcome User!'),
          PieChart(
            dataMap: {
              'Protein': totalConsumedSample['protein'] ?? 0,
              'Carbs': totalConsumedSample['carbs'] ?? 0,
              'Fat': totalConsumedSample['fat'] ?? 0,
            },
            // chartType: ChartType.ring,
            // totalValue: 100,
            // chartRadius: 100.0,
            // legendOptions: const LegendOptions(showLegends: false),
            baseChartColor: Colors.grey[50]!.withOpacity(0.15),
            centerText: '${totalConsumedSample['calories'] ?? 0} kcal',
            // centerTextStyle: TextStyle(color: Colors.white),
            // chartValuesOptions: const ChartValuesOptions(
            //     showChartValueBackground: false, showChartValues: false),
            formatChartValues: (val) => '$val g',
          ),
          GridView(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            children: [
              MealButton(name: 'Breakfast', meals: getBreakfast()),
              MealButton(name: 'Lunch', meals: getLunch()),
              MealButton(name: 'Dinner', meals: getDinner()),
              MealButton(name: 'Snacks', meals: getSnacks())
            ],
          )
        ],
      ),
    );
  }
}
