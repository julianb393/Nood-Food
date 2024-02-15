import 'package:flutter/material.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final NFUser user;
  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double _consumedProtein;
  late double _consumedCarbs;
  late double _consumedFat;

  void _computeConsumedMacros(List<Food> foods) {
    _consumedProtein = 0.0;
    _consumedCarbs = 0.0;
    _consumedFat = 0.0;
    for (Food food in foods) {
      _consumedProtein += food.computeConsumedProtein();
      _consumedCarbs += food.computeConsumedCarbs();
      _consumedFat += food.computeConsumedFat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Food> foods = Provider.of<List<Food>>(context);
    _computeConsumedMacros(foods);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PieChart(
                dataMap: {
                  'Protein': _consumedProtein,
                  'Carbs': _consumedCarbs,
                  'Fat': _consumedFat,
                },
                baseChartColor: Colors.grey[50]!.withOpacity(0.15),
                centerText: '${computeTotalCalories(
                  _consumedProtein,
                  _consumedCarbs,
                  _consumedFat,
                ).toStringAsFixed(2)} kcal',
                formatChartValues: (val) => '${val.toStringAsFixed(2)} g',
              ),
              const Text('You have xxx calories remaining.'),
            ],
          )
        ],
      ),
    );
  }
}
