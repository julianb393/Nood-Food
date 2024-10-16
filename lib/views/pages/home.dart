import 'dart:math';

import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/date_picker.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
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
    int remainingCalories =
        ((widget.user.calorieLimit ?? 0) - consumedCalories).toInt();
    bool isLimitSet = (widget.user.calorieLimit ?? 0) > 0;
    Color progressColor = isLimitSet ? Colors.green : Colors.amber;
    double progress =
        isLimitSet ? min(widget.user.calorieLimit!, consumedCalories) : 1;

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
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DashedCircularProgressBar.aspectRatio(
                aspectRatio: 1.5,
                progress: progress,
                maxProgress: isLimitSet ? widget.user.calorieLimit! : 1,
                foregroundColor:
                    isLimitSet && remainingCalories < 0
                    ? Colors.red
                    : progressColor,
                backgroundColor: Colors.grey,
                foregroundStrokeWidth: 20,
                backgroundStrokeWidth: 20,
                seekSize: remainingCalories <= 0 ? 0 : 15,
                seekColor: Colors.greenAccent,
                animation: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${consumedCalories.toInt()}',
                      style: TextStyle(
                          color: isLimitSet && remainingCalories < 0
                              ? Colors.red
                              : progressColor,
                          fontSize: 40),
                    ),
                    const Text(
                      'Calories Consumed',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              PrimerProgressBar(
                segments: [
                  Segment(
                    value: _consumedProtein.toInt(),
                    color: Colors.blue,
                    label: const Text('Protein (g)'),
                  ),
                  Segment(
                    value: _consumedFat.toInt(),
                    color: Colors.red,
                    label: const Text('Fat (g)'),
                  ),
                  Segment(
                    value: _consumedCarbs.toInt(),
                    color: Colors.purple,
                    label: const Text('Carbs (g)'),
                  )
                ],
              ),
              isLimitSet
                  ? Text(
                      remainingCalories >= 0
                          ? 'You have $remainingCalories calories remaining'
                          : 'You have consumed a surplus of ${(remainingCalories) * -1} calories',
                    )
                  : const Text(
                      'Set your calorie limit in your Account settings'),
            ],
          )
        ],
      ),
    );
  }
}
