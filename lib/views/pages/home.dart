import 'package:flutter/material.dart';
import 'package:nood_food/common/date_picker.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/util/style.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final NFUser user;
  final Function(DateTime) updateDate;
  final Function getSelectedDate;
  const Home({
    super.key,
    required this.user,
    required this.updateDate,
    required this.getSelectedDate,
  });

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
    double consumedCalories =
        computeTotalCalories(_consumedProtein, _consumedCarbs, _consumedFat);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DatePicker(
                selectedDate: widget.getSelectedDate(),
                changeDay: (day) => widget.updateDate(day),
              ),
              StyledText.titleLarge('Welcome ${widget.user.displayName}'),
            ],
          ),
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
                centerText: '${consumedCalories.toStringAsFixed(2)} kcal',
                formatChartValues: (val) => '${val.toStringAsFixed(2)} g',
              ),
              widget.user.calorieLimit != null
                  ? Text(
                      'You have ${(widget.user.calorieLimit! - consumedCalories).toStringAsFixed(2)} calories remaining.')
                  : const SizedBox(),
            ],
          )
        ],
      ),
    );
  }
}
