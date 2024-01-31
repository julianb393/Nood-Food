import 'package:flutter/material.dart';
import 'package:nood_food/views/meal_details.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MealDetails(mealName: 'Breakfast'),
    );
  }
}
