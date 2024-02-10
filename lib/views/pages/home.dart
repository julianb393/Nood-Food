import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/style.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:weekly_date_picker/weekly_date_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime _selectedDay = DateTime.now();

  late double _consumedProtein;
  late double _consumedCarbs;
  late double _consumedFat;

  void _computeConsumedMacros(List<Food> foods) {
    _consumedProtein = 0.0;
    _consumedCarbs = 0.0;
    _consumedFat = 0.0;
    for (Food food in foods) {
      _consumedProtein += food.protein;
      _consumedCarbs += food.carbs;
      _consumedFat += food.fat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Food> foods = Provider.of<List<Food>>(context);
    _computeConsumedMacros(foods);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
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
            ],
          ),
          const SizedBox(height: 20.0),
          StyledText.titleLarge('Welcome User!'),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PieChart(
                  dataMap: {
                    'Protein': _consumedProtein,
                    'Carbs': _consumedCarbs,
                    'Fat': _consumedFat,
                  },
                  // chartType: ChartType.ring,
                  // totalValue: 100,
                  // chartRadius: 100.0,
                  // legendOptions: const LegendOptions(showLegends: false),
                  baseChartColor: Colors.grey[50]!.withOpacity(0.15),
                  centerText: '${computeTotalCalories(
                    _consumedProtein,
                    _consumedCarbs,
                    _consumedFat,
                  ).toStringAsFixed(2)} kcal',
                  // centerTextStyle: TextStyle(color: Colors.white),
                  // chartValuesOptions: const ChartValuesOptions(
                  //     showChartValueBackground: false, showChartValues: false),
                  formatChartValues: (val) => '${val.toStringAsFixed(2)} g',
                ),
                const Text('You have xxx calories remaining.')
              ],
            ),
          )
        ],
      ),
    );
  }
}
